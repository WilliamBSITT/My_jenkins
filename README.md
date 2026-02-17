
 # Running your own Jenkins instance

 ## Docker Compose

 ### Prerequisites

 - Docker
 - Docker Compose (or the `docker compose` plugin)

 When cloning this repository, you will find a `docker-compose.yml` file at the root.

 **Note:** You must provide some environment variables (see `.env.example`).
 - `JENKINS_ADMIN_PASSWORD` - admin password
 - `JENKINS_DEVELOPER_PASSWORD` - developer password
 - `NGROK_AUTHTOKEN` - ngrok authentication token
 - `NGROK_DOMAIN` - ngrok domain (optional)

 Run:

 ```bash
 docker compose up --build -d
 ```

 Your Jenkins instance will be available at `http://localhost:8080` (or `https://YOUR_DOMAIN_NAME` if configured).

 Security note: Do not commit private keys or secrets (for example `jenkins_github_key`) into the repository. Store secrets in a safe place and use the `.env` file or secret manager at deployment time.



