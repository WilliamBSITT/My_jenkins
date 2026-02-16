folder("Projects") {
    description("The available projets.")
}

freeStyleJob("link-project") {
    parameters {
        stringParam("GIT_URL", null, 'Git repository url')
        stringParam("DISPLAY_NAME", null, "Display name for the job")

        choiceParam("TRIGGER_TYPE", ["GITHUB_WEBHOOK", "CRON"], "Choisissez comment déclencher le build")
        activeChoiceReactiveReferenceParam("TRIGGER_CONFIG_HELP") {
            choiceType("FORMATTED_HTML")
            referencedParameter("TRIGGER_TYPE")
            groovyScript {
                script("""
                    if (TRIGGER_TYPE == "CRON") {
                        return '''
                        <div style="margin-top: 15px; font-family: sans-serif;">                            
                            <div style="background-color: #eeeeee; color: #000 !important; padding: 16px; border-left: 6px solid #e82929; border-radius: 4px; box-shadow: 0 4px 8px rgba(0,0,0,0.3);">
                                <strong style="color: #e82929;">⏱ Aide mémoire Syntaxe Cron</strong><br><br>
                                <div style="font-size: 0.9em; line-height: 1.4; color: #000 !important;">
                                    La syntaxe comporte 5 champs : <code>MINUTEs HEUREs JOURs MOIS JOURS_SEMAINE</code><br><br>
                                    • <b>H</b> : Utilise le "Hash" Jenkins pour éviter que tous les builds démarrent pile à la même seconde (répartition de charge).<br>
                                    • <b>H/15 * * * *</b> : Toutes les 15 minutes.<br>
                                    • <b>H H(0-5) * * *</b> : Une fois par jour entre minuit et 5h du matin.<br>
                                    • <b>H 12 * * 1-5</b> : Une fois par jour à midi, du lundi au vendredi.<br><br>
                                    <i>Note : Les espaces entre les étoiles sont obligatoires.</i>
                                </div>
                            </div>
                        </div>
                        <input value="" type="hidden">
                        '''
                    } else {
                        return '''
                        <div style="
                            background-color: #eeeeee; 
                            color: #000000 !important;
                            padding: 16px; 
                            border-left: 6px solid #e82929; 
                            border-radius: 4px;
                            font-family: sans-serif;
                            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
                            margin: 10px 0;
                        ">
                            <strong style="color: #e82929; font-size: 1.1em;">Configuration du Webhook GitHub</strong><br><br>
                            <div style="line-height: 1.6; color: #000000 !important;">
                                1. Va sur ton repo GitHub : <b style="color: #0056b3;">Settings > Webhooks > Add webhook</b>.<br>
                                2. <b>Payload URL :</b> Ajoute <code style="color: #000;">/github-webhook/</code> à la fin de ton URL ngrok.<br>
                                3. <b>Content type :</b> Choisis <code style="color: #000;">application/json</code>.<br>
                                4. <b>Events :</b> Laisse sur <i>Just the push event</i>.<br>
                                5. Active le webhook.<br><br>
                                <div style="background: rgba(0,0,0,0.08); padding: 8px; border-radius: 4px; font-size: 0.9em; color: #000000 !important;">
                                    <i>Exemple : https://votre-id.ngrok-free.app/github-webhook/</i>
                                </div>
                            </div>
                            <input value="" type="hidden">
                        </div>
                        '''
                    }
                """.stripIndent())
                fallbackScript("return '<i>Erreur de script</i>'")
            }
        }
        stringParam("TRIGGER_CONFIG", "H/15 * * * *", "Fréquence du build (uniquement si CRON est sélectionné)")
        stringParam("CREDENTIALS_ID", "my-git-token", "Credentials ID")


    }
    steps {
        dsl {
            text('''
                pipelineJob("Projects/$DISPLAY_NAME") {
                    properties {
                            githubProjectProperty {
                                projectUrlStr('$GIT_URL')
                            }
                        }
                    definition {
                        cps {
                            script("""
                                node {
                                    try {
                                        stage('Checkout') {
                                            cleanWs()
                                            sh "echo '--- Disk Usage Before Build ---' && df -h /var/lib/docker || df -h /"
                                            
                                            checkout scmGit(
                                                userRemoteConfigs: [[url: '$GIT_URL', credentialsId: '$CREDENTIALS_ID']],
                                                branches: [[name: '*/main'], [name: '*/master']]
                                            )
                                        }

                                        stage('Validation & Execution') {
                                            if (fileExists('Jenkinsfile')) {
                                                echo "Jenkinsfile found, launching pipeline"
                                                load 'Jenkinsfile'
                                                
                                            } else {
                                                echo "--- No Jenkinsfile found ---"
                                            }
                                        }
                                    } finally {
                                        stage('Cleanup') {
                                            echo "cleanWs() to free up workspace disk space"
                                        }
                                    }
                                }
                                
                            """.stripIndent())
                            sandbox(true)
                        }
                    }
                    if ("$TRIGGER_TYPE" == "GITHUB_WEBHOOK") {
                        triggers {
                            githubPush()
                        }
                    } else {
                        triggers {
                            // scm("H/1 * * * *")
                            scm("${TRIGGER_CONFIG}".toString())
                        }
                    }
                }
                queue("Projects/$DISPLAY_NAME")
            ''')
        }
    }
}

freeStyleJob("docker-garbage-collector") {
    description("Nettoyage automatique des images Docker inutilisées sur l'instance.")
    
    // Syntaxe Cron : Minute Heure Jour Mois Jour_de_la_semaine
    // 0 9 * * 1 -> 09:00 le lundi
    triggers {
        cron("0 9 * * 1")
    }

    steps {
        shell('''
            echo "Prune unused Docker images older than 7 days..."
            docker image prune -af --filter "until=168h"
            
            # Supprime les volumes orphelins
            docker system prune -f --volumes
            
            echo "Status of disk after cleanup:"
            df -h /var/lib/docker || df -h /
        ''')
    }
}