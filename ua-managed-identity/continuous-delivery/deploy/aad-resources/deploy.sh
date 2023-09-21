#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX
[[ -z "$DEPLOYMENT_LOCATION" ]] && echo -n "Enter an Environment Location (ex. eastus2): " && read DEPLOYMENT_LOCATION

# create resource group for resources.
az group create --name rg-$DEPLOYMENT_SUFFIX \
    --location $DEPLOYMENT_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX

# create devops resource group.
RESOURCE_GROUP_NAME=rg-$DEPLOYMENT_SUFFIX-devops
az group create --name $RESOURCE_GROUP_NAME \
    --location $DEPLOYMENT_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX

# get subscription id.
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# create a service principal to be used by the pipeline. 
SERVICE_PRINCIPAL_NAME=sp-$DEPLOYMENT_SUFFIX-cd
SERVICE_PRINCIPAL_AUTH=$(az ad sp create-for-rbac --display-name $SERVICE_PRINCIPAL_NAME --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-$DEPLOYMENT_SUFFIX)
SERVICE_PRINCIPAL_APP_ID=$(jq -r '.appId' <<< "$SERVICE_PRINCIPAL_AUTH")
SERVICE_PRINCIPAL_SECRET=$(jq -r '.password' <<< "$SERVICE_PRINCIPAL_AUTH")

# get service principal id.
SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name "$SERVICE_PRINCIPAL_NAME" --query [].id -o tsv)

# create a keyvault.
VAULT_NAME=kv-$DEPLOYMENT_SUFFIX-devops
az keyvault create --name $VAULT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $DEPLOYMENT_LOCATION \
    --tags env=$DEPLOYMENT_SUFFIX

# create keys.
az keyvault secret set --vault-name $VAULT_NAME --name "$DEPLOYMENT_SUFFIX-sp-app-id" --value $SERVICE_PRINCIPAL_APP_ID
az keyvault secret set --vault-name $VAULT_NAME --name "$DEPLOYMENT_SUFFIX-sp-name"   --value $SERVICE_PRINCIPAL_NAME
az keyvault secret set --vault-name $VAULT_NAME --name "$DEPLOYMENT_SUFFIX-sp-secret" --value $SERVICE_PRINCIPAL_SECRET
 
# create azure ad group for SQL Server admins.
sql_admins_group=$(az ad group create --display-name "SQLAdmins-$DEPLOYMENT_SUFFIX" --mail-nickname "SQLAdmins-$DEPLOYMENT_SUFFIX")
sql_admins_group_id=$(jq -r '.id' <<< "$sql_admins_group")
sql_admins_group_name=$(jq -r '.displayName' <<< "$sql_admins_group")

# create azure ad group for SQL Server .
sql_admins_group=$(az ad group create --display-name "SQLDBAccess-$DEPLOYMENT_SUFFIX" --mail-nickname "SQLDBAccess-$DEPLOYMENT_SUFFIX")

# add member to group.
az ad group member add --group $sql_admins_group_id --member-id $SERVICE_PRINCIPAL_ID