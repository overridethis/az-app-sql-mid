#!/bin/bash
[[ -z "$MANAGED_IDENTITY" ]] && echo -n "Enter Managed Identity name: " && read MANAGED_IDENTITY
[[ -z "$RESOURCE_GROUP" ]] && echo -n "Enter Managed Identity resource group: " && read RESOURCE_GROUP

# create an identity for it.
az identity show --name $MANAGED_IDENTITY --resource-group $RESOURCE_GROUP 

# get service principal for managed identity.
PRINCIPAL_ID=$(az identity show --name $MANAGED_IDENTITY --resource-group $RESOURCE_GROUP --query clientId --out tsv)

# get graph id permissions (User.Read.All)
GRAPH_RESOURCE_ID=$(az ad sp list --display-name "Microsoft Graph" --query [0].appId --out tsv)
APP_ROLE_ID=$(az ad sp list --display-name "Microsoft Graph" --query "[0].appRoles[?value=='User.Read.All' && contains(allowedMemberTypes, 'Application')].id" --output tsv)

echo "Principal ID: $PRINCIPAL_ID"
echo "Graph Resource ID: $GRAPH_RESOURCE_ID"
echo "App Role ID (User.Read.All): $APP_ROLE_ID"

az ad app permission add --id $PRINCIPAL_ID --api $GRAPH_RESOURCE_ID --api-permissions $APP_ROLE_ID=Scope