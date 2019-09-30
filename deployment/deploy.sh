#!/bin/bash
set -a # automatically export all variables
source .env
set +a
aws cloudformation deploy --template-file cloudformation.yaml --stack-name \
$STACK_NAME --tags Project=$PROJECT --parameter-overrides \
DBName=$DB_NAME DBUser=$DB_USER DBPassword=$DB_PASSWORD JwtSecret=$JWT_SECRET \
--region $REGION --capabilities CAPABILITY_IAM
