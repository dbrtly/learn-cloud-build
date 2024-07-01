# Cloud Build Meta Tools

Should you build community builders from source to your private artifact 
registry? Is this required to integrate all the required security scans?

The Cloud Build meta-trigger deploys a Cloud Build trigger and build definiton 
that in turn detects and deploys Cloud Build triggers distributed throughout the 
repository when the triggers change. The objective is to simplify Cloud Build 
trigger management. For example, it will detect and deploy a trigger created at 
`projects/quickstart/.cloudbuild.trigger.yaml`.

## Prerequisites

The Cloud Build-GitHub integration revolves around the Cloud Build GitHub App.
You must install that manually, create a Personal Access Token and export the
GITHUB_PAT and INSTALLATION_ID as environment variables.

Your installation ID can be found in the URL of your Cloud Build GitHub App. 
Example: from following URL `https://github.com/settings/installations/1234567`
installation_id is `INSTALLATION_ID=1234567`.

Set the following environment variables in the file `core/cloudbuild/.env` and 
execute:

- GOOGLE_PROJECT_ID
- GITHUB_PAT
- INSTALLATION_ID

```shell
cd $project_root/core/cloudbuild/
chmod +x setup.sh
./setup.sh

```
