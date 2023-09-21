#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX
[[ -z "$DEPLOYMENT_LOCATION" ]] && echo -n "Enter an Environment Location (ex. eastus2): " && read DEPLOYMENT_LOCATION
[[ -z "$MOCKAROO_API_KEY" ]] && echo -n "Enter a Mockaroo API Key: " && read MOCKAROO_API_KEY

# get azure ad group for SQL Server.
SQL_ADMINS_GROUP_NAME="SQLAdmins-$DEPLOYMENT_SUFFIX"
SQL_ADMINS_GROUP_ID=$(az ad group list --display-name $SQL_ADMINS_GROUP_NAME --query [].id -o tsv)

# create resource group (this should already be created).
RESOURCE_GROUP_NAME=rg-$DEPLOYMENT_SUFFIX
az group create --name $RESOURCE_GROUP_NAME \
    --location $DEPLOYMENT_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX

# deploy to azure.
az stack group create \
    --name TeamMembers \
    --deny-settings-mode 'denyWriteAndDelete' \
    --template-file main.bicep \
    --resource-group $RESOURCE_GROUP_NAME \
    --parameters suffix=$DEPLOYMENT_SUFFIX \
        mockarooApiKey=$MOCKAROO_API_KEY \
        sqlAdminsGroupSecurityName=$SQL_ADMINS_GROUP_NAME \
        sqlAdminsGroupSecurityIdentifier=$SQL_ADMINS_GROUP_ID \
    --yes
