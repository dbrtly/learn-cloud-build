# Vendored Code from:
# https://raw.githubusercontent.com/GoogleCloudPlatform/cloud-builders-community/master/cancelot/README.md

# Trivy

[Trivy](https://github.com/aquasecurity/trivy) is a Simple and Comprehensive Vulnerability Scanner for Containers, Suitable for CI.

## Usage:

```
steps:
- name: 'gcr.io/$PROJECT_ID/trivy'
  args: ['--format', 'json', '--output', 'scan_report.json', 'python:3.4-alpine']
```
