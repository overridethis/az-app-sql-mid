#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX
[[ -z "$ENV_LOCATION" ]] && echo -n "Enter an Environment Location (ex. eastus2): " && read ENV_LOCATION
[[ -z "$MOCKAROO_API_KEY" ]] && echo -n "Enter a Mockaroo API Key: " && read MOCKAROO_API_KEY

# create resource group.
RESOURCE_GROUP_NAME=rg-$DEPLOYMENT_SUFFIX
az group create --name $RESOURCE_GROUP_NAME \
    --location $ENV_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX

# deploy to azure.
az deployment group create --template-file main.bicep \
    --resource-group {NAME_OF_RESOURCE_GROUP}
    --location eastus2 \
    --parameters suffix=$DEPLOYMENT_SUFFIX mockarooApiKey=$MOCKAROO_API_KEY