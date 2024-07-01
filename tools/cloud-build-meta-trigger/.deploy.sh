#!/bin/bash

for environment in prod test
do
    gcloud config set project my-gcp-project-${environment}

    # validate builder is available in this GCP project
    gcloud container images list --filter meta-triggers

    # create trigger from manifest
    cd ../..
    if [[ "${environment}" == "prod" ]]; then
        gcloud builds triggers import --source=cloudbuild.trigger.yaml
    else
        gcloud builds triggers import --source=${env_abbreviation}/cloudbuild.trigger.yaml
    fi
    
done
    
