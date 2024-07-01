#/bin/bash

set -euo pipefail

# Load environment variables
source .env

# The Cloud Build-GitHub integration revolves around the Cloud Build GitHub App.
# You must install it manually.

# Create a robot account in GitHub, add it to your organisation and grant it read 
# permission on your git repository. Install the GitHub app for the robot account.

# GitHub App installation ID can be found in the URL of your Cloud Build GitHub App. 
# Example: from following URL, https://github.com/settings/installations/1234567,  
# ```GITHUB_INSTALLATION_ID=1234567```.
: "${GITHUB_INSTALLATION_ID}"

# Create a Personal Access Token and export GITHUB_PAT as an environment variable.
: "${GITHUB_PAT}"

# confirm explicit Google Project ID
: "${GOOGLE_PROJECT_ID}"

# confirm explicit Google user identity
: "${GOOGLE_USER}"

# explicitly set Google project id
gcloud config set project "${GOOGLE_PROJECT_ID}"
gcloud config set account "${GOOGLE_USER}"

USER_ACTIVE=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
if [[ "${USER_ACTIVE}" != "${GOOGLE_USER}" ]]; then 
    echo Follow the interactive prompts to login to Google Cloud.
    gcloud auth login "${GOOGLE_USER}"
else
    echo "${GOOGLE_USER}" is the active account for the gcloud CLI.
fi

# Affirm gcloud api are enabled
gcloud services enable \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    containerregistry.googleapis.com \
    secretmanager.googleapis.com

# enable service account permissions to use Cloud Build API
# GOOGLE_PROJECT_ID=$(gcloud config list --format="value(core.project)")
GOOGLE_PROJECT_NUMBER=$(gcloud projects describe ${GOOGLE_PROJECT_ID} --format="value(projectNumber)")
CLOUD_BUILD_SERVICE_AGENT="service-${GOOGLE_PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com"

CONNECTION_NAME="dbrtly"
GOOGLE_REGION=us-central1
REPO_OWNER=dbrtly
REPO_NAME=learn-cloud-build
REPO_URI=https://github.com/${CONNECTION_NAME}/${REPO_NAME}.git
SECRET_NAME=github_pat_${REPO_OWNER}

# enable service account permission to create connections via gcloud
# as recommended by google docs: 
# https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=2nd-gen#iam_perms
gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SERVICE_AGENT}" \
  --role="roles/secretmanager.admin"

# create GITHUB_PAT as secret in secrets manager - idempotent?
CURRENT_STATE=$(gcloud secrets describe $SECRET_NAME)
if [[ $? -ne 0]]; then
    echo -n $GITHUB_PAT | gcloud secrets create ${SECRET_NAME} --data-file=-
fi

# enable service account permission to access the secret
gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
    --member="serviceAccount:${CLOUD_BUILD_SERVICE_AGENT}" \
    --role="roles/secretmanager.secretAccessor"

# create connection to GitHub in Cloud Build
CURRENT_STATE=$(gcloud builds connections describe $CONNECTION_NAME \
    --region $GOOGLE_REGION \
    --format "value(installationState.stage)" \
)
if [[ -n $CURRENT_STATE ]]; then
    gcloud builds connections create github ${CONNECTION_NAME} \
        --authorizer-token-secret-version projects/${GOOGLE_PROJECT_ID}/secrets/${SECRET_NAME}/versions/1  \
        --app-installation-id ${GITHUB_INSTALLATION_ID} \
        --region ${GOOGLE_REGION}
if [[ $CURRENT_STATE -eq "PENDING_INSTALL_APP" ]]; then
    echo Have you installed the GitHub app yet?
    echo 
fi

# verify connection is complete
CURRENT_STATE=$(gcloud builds connections describe $CONNECTION_NAME \
    --region $GOOGLE_REGION \
    --format "value(installationState.stage)" \
)

# Register a Cloud Build repository associated with the Cloud Build connection
CURRENT_STATE=$(gcloud builds repositories describe ${REPO_NAME} \
  --connection $CONNECTION_NAME \
  --region $GOOGLE_REGION \
  --format "value(remoteUri)" \
) &> /dev/null
if [[ -n "${CURRENT_STATE}" ]]; then
    echo Creating the repository in Cloud Build
    gcloud builds repositories create ${REPO_NAME} \
        --remote-uri ${REPO_URI} \
        --connection ${CONNECTION_NAME} \
        --region ${GOOGLE_REGION}
fi
if [[ -v "${REMOTE_URI_CURRENT}" ]] && [[ "${REMOTE_URI_CURRENT}" != "${REPO_URI}" ]]; then
    echo Repository exists with different Uri. 
    echo Please check and adjust the repository name against existing repositories
    exit 1
fi

# get meta-cloud-build tools
git clone https://github.com/jthegedus/meta-cloud-builders

# meta-triggers
cd ../meta-cloud-builders/meta-triggers

for environment in prod test
do
    gcloud config set project my-gcp-project-${environment}
    gcloud builds submit .
    gcloud container images list --filter meta-triggers
done
    