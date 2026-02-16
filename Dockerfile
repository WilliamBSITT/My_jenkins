FROM jenkins/jenkins:lts

USER root
RUN apt-get update \
    && apt-get -y install \
        ca-certificates \
        curl \
        git \
    && curl -fsSL https://get.docker.com | sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker jenkins
COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY jenkins /jenkins
ENV CASC_JENKINS_CONFIG /jenkins/config.yml
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
