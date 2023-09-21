#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX

# Delete resource group.
RESOURCE_GROUP_NAME=rg-$DEPLOYMENT_SUFFIX
az stack group delete \
    --name TeamMembers \
    --resource-group $RESOURCE_GROUP_NAME \
    --delete-resources \
    --yes