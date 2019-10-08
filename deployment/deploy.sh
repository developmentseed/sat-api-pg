#!/bin/bash
set -a # automatically export all variables
source .env
set +a
SQITCH_CMD=./sqitch
aws ecr get-login --region $REGION --no-include-email | sh

yarn subzero cloud deploy --dba $SUPER_USER --password $SUPER_USER_PASSWORD \
--openresty-image-tag latest
