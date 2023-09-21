#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX

# create a service principal to be used by the pipeline. 
SERVICE_PRINCIPAL_NAME=sp-$DEPLOYMENT_SUFFIX-cd
SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name "$SERVICE_PRINCIPAL_NAME" --query [].appId -o tsv)
az ad sp delete --id $SERVICE_PRINCIPAL_ID

# delete azure group for SQL Server admins.
az ad group delete --display-name "SQLAdmins-$DEPLOYMENT_SUFFIX"

# Delete resource group.
az group delete --resource-group="rg-$DEPLOYMENT_SUFFIX-devops" --yes