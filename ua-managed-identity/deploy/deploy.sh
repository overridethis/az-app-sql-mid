#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX
[[ -z "$ENV_LOCATION" ]] && echo -n "Enter an Environment Location (ex. eastus2): " && read ENV_LOCATION

RESOURCE_GROUP_NAME=rg-$DEPLOYMENT_SUFFIX
az group create --name $RESOURCE_GROUP_NAME \
    --location $ENV_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX
