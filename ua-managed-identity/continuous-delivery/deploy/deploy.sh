#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX
[[ -z "$DEPLOYMENT_LOCATION" ]] && echo -n "Enter an Environment Location (ex. eastus2): " && read DEPLOYMENT_LOCATION
[[ -z "$MOCKAROO_API_KEY" ]] && echo -n "Enter a Mockaroo API Key: " && read MOCKAROO_API_KEY

# get user_id of service principal.
user_id=$(az ad signed-in-user show --query id -o tsv)

# create azure ad group for SQL Server.
sql_admins_group=$(az ad group create --display-name "SQLAdmins-$DEPLOYMENT_SUFFIX" --mail-nickname "SQLAdmins-$DEPLOYMENT_SUFFIX")
sql_admins_group_id=$(jq -r '.id' <<< "$sql_admins_group")
sql_admins_group_name=$(jq -r '.displayName' <<< "$sql_admins_group")

# # add member to group.
az ad group member add --group $sql_admins_group_id --member-id $user_id

# create resource group.
RESOURCE_GROUP_NAME=rg-$DEPLOYMENT_SUFFIX
az group create --name $RESOURCE_GROUP_NAME \
    --location $DEPLOYMENT_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX

# # deploy to azure.
az deployment group create --template-file main.bicep \
    --resource-group $RESOURCE_GROUP_NAME \
    --parameters suffix=$DEPLOYMENT_SUFFIX \
        mockarooApiKey=$MOCKAROO_API_KEY \
        sqlAdminsGroupSecurityName=$sql_admins_group_name \
        sqlAdminsGroupSecurityIdentifier=$sql_admins_group_id
