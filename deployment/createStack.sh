#!/bin/bash
set -a # automatically export all variables
source .env
set +a
DefaultCount=0
Count=${1:-$DefaultCount}
aws cloudformation deploy \
  --template-file cloudformation.yaml \
  --stack-name $STACK_NAME \
  --tags Project=$PROJECT \
  --parameter-overrides \
    DBSuperUser=$SUPER_USER \
    DBSuperPassword=$SUPER_USER_PASSWORD \
    DBName=$DB_NAME \
    DBUser=$DB_USER \
    DBPassword=$DB_PASS \
    JwtSecret=$JWT_SECRET \
    DesiredCount=$Count \
    OpenRestyImage=$OPEN_RESTY_IMAGE \
    ECSAMI=$ECSAMI \
  --region $REGION \
  --capabilities CAPABILITY_IAM \
