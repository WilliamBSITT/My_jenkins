# Template

This directory contains some example Jenkins pipelines and templates to help you get started with Jenkins projects.

- **Purpose:** 
Provide sample `Jenkinsfile`s and test scripts to demonstrate CI flow and make it easier to adapt to your projects.

- **Jenkinsfile examples:**
	- A C example is provided in the `template/c` directory (see `Jenkinsfile`).
	- A Python example is provided in the `template/python` directory (see `Jenkinsfile`).

- **`test.sh` template:**
	- Each sub-template includes a `test.sh` script showing how to run tests inside a container or in CI.

# Important notes:

- These files are educational examples - adapt the steps (install, build, test, archive) to your project's needs.
- If you need to start from scratch, keep the XML logic used to describe jobs/parameters to ensure compatibility with Jenkins and the Job DSL.
- Verify and adjust environment variables, paths, and referenced Docker images before running in your infrastructure.
