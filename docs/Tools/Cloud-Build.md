# Learn Cloud Build

I like the following differentiators compared to GitHub Workflows:

- Simplified IAM. 
Cloud Build jobs are just another GCP resource type and run as a GCP service account with
conventional roles and permissions.

- simplified secret management.
Cloud Build leverages Cloud Secrets Manager 

- reduced boilerplate steps
It's at least the year 2024. Apps typically run in container images. CI workflows can also
run in a container image. Packaging apps including build tools as containers provides
reusability.

## Runner-agnostic sequence of container images in a single workspace

Cloud Build has a core workflow abstraction as a workspace that executes a sequence of
container images. This is not necessarily a exclusive characteristic. A runner-agnostic 
approach is possible and might explore that idea later. 

It's possible to setup Workload Identity Federation to intergrate GitHub and GCP IAM. 
It's possible to use Cloud Secrets Manager via the [Google GitHub Action "Get SecretManager Secrets"](https://github.com/google-github-actions/get-secretmanager-secrets).
It's possible to use the [Docker Run Action](https://github.com/addnab/docker-run-action).

Consistently following this approach would require opinionated style and discipline. The
path of least resistance is to use GitHub action the way most people use it: a loose
sequenced collection of functions with inconsistent style abnd conventions.
