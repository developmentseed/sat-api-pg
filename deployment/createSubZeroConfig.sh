#!/bin/bash
set -a # automatically export all variables
source .env
set +a
PRODUCTION_DB_HOST=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
--query "Stacks[0].Outputs[?OutputKey=='RDSHost'].OutputValue" --output text)
DOMAIN=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
--query "Stacks[0].Outputs[?OutputKey=='RESTEndpoint'].OutputValue" --output text)
SUBZERO_APP_CONF=$(cat <<EOF
{
  "name": "$STACK_NAME",
  "domain": "",
  "openresty_repo": "${OPENRESTY_REPO_URI}",
  "db_location": "external",
  "db_admin": "${SUPER_USER}",
  "db_host": "${PRODUCTION_DB_HOST}",
  "db_port": 5432,
  "db_name": "${DB_NAME}",
  "version": "v0.0.1"
}
EOF
)

echo "${SUBZERO_APP_CONF}" > ../subzero-app.json
