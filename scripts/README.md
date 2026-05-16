# Scripts

This folder stores local helper scripts for platform operators.

## `backend.sh`

`backend.sh` creates or reuses the S3 bucket used by Terraform remote state and
writes a backend file for the selected environment.

Defaults:

- `PROJECT_NAME=petclinic`
- `ENVIRONMENT=dev`
- `AWS_REGION=us-east-2`
- `BACKEND_FILE=terraform/environments/${ENVIRONMENT}/backend.tf`
- `BACKEND_KEY=${PROJECT_NAME}/${ENVIRONMENT}/terraform.tfstate`
- `BUCKET_NAME=${PROJECT_NAME}-tfstate-${AWS_ACCOUNT_ID}`

Example:

```bash
AWS_REGION=us-east-2 ENVIRONMENT=dev ./scripts/backend.sh
```

The script enables versioning, AES256 encryption, and public access blocking on
the state bucket.
