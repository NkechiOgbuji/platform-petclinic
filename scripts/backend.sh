#!/bin/bash

set -euo pipefail

PROJECT_NAME="${PROJECT_NAME:-petclinic}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
REGION="${AWS_REGION:-us-east-2}"
BACKEND_FILE="${BACKEND_FILE:-terraform/environments/${ENVIRONMENT}/backend.tf}"
BACKEND_KEY="${BACKEND_KEY:-${PROJECT_NAME}/${ENVIRONMENT}/terraform.tfstate}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="${BUCKET_NAME:-${PROJECT_NAME}-tfstate-${ACCOUNT_ID}}"

echo "Configuring Terraform backend remote..."
echo "Bucket: ${BUCKET_NAME}"
echo "Region: ${REGION}"
echo "State key: ${BACKEND_KEY}"
echo "Backend file: ${BACKEND_FILE}"

if aws s3api head-bucket --bucket "${BUCKET_NAME}" >/dev/null 2>&1; then
  echo "S3 bucket already exists. Reusing it."
else
  echo "Creating Terraform backend S3 bucket..."
  if [ "${REGION}" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "${BUCKET_NAME}" \
      --region "${REGION}"
  else
    aws s3api create-bucket \
      --bucket "${BUCKET_NAME}" \
      --region "${REGION}" \
      --create-bucket-configuration LocationConstraint="${REGION}"
  fi
fi

aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

mkdir -p "$(dirname "${BACKEND_FILE}")"

cat > "${BACKEND_FILE}" <<EOF
terraform {
  backend "s3" {
    bucket  = "${BUCKET_NAME}"
    key     = "${BACKEND_KEY}"
    region  = "${REGION}"
    encrypt = true
  }
}
EOF

echo ""
echo "Terraform backend remote is ready."
echo "Populated ${BACKEND_FILE}"