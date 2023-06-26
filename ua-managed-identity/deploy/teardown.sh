#!/bin/bash
[[ -z "$DEPLOYMENT_SUFFIX" ]] && echo -n "Enter a Deployment Suffix: " && read DEPLOYMENT_SUFFIX

# Delete resource group.
az group delete --resource-group rg-$DEPLOYMENT_SUFFIX --yes
