#!/bin/bash
set -a # automatically export all variables
source .env
set +a
aws cloudformation deploy --template-file newCloudformation.yaml --stack-name \
$STACK_NAME --tags Project=$PROJECT --parameter-overrides \
DBSuperUser=$SUPER_USER DBSuperPassword=$SUPER_USER_PASSWORD \
DBName=$DB_NAME DBUser=$DB_USER DBPassword=$DB_PASS JwtSecret=$JWT_SECRET \
--region $REGION --capabilities CAPABILITY_IAM
