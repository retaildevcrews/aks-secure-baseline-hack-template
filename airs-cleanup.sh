#!/bin/bash

# ignore errors and clean up all we can
set +e

# change to the proper directory
cd $(dirname $0)

if [ -z "$1" ]
then
  echo Team Name param missing
  exit 1
fi

if [ "$#" == 1 ] || [ $2 != "-y" ]
then
  read -p "WARNING: This will delete all resources! Are you sure? (y/n) " response

  if ! [[ $response =~ [yY] ]]
  then
    exit 0;
  fi
fi

ASB_TEAM_NAME=$1

# resource group names
export ASB_CORE_RG=rg-${ASB_TEAM_NAME}-core
export ASB_HUB_RG=rg-${ASB_TEAM_NAME}-networking-hub
export ASB_SPOKE_RG=rg-${ASB_TEAM_NAME}-networking-spoke

export ASB_AKS_NAME=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksClusterName.value -o tsv)
export ASB_KEYVAULT_NAME=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.keyVaultName.value -o tsv)
export ASB_LA_HUB=$(az monitor log-analytics workspace list -g $ASB_HUB_RG --query [0].name -o tsv)

if [ -v "$ASB_KEYVAULT_NAME" ]
then
  # delete and purge the key vault
  az keyvault delete -n $ASB_KEYVAULT_NAME
  az keyvault purge -n $ASB_KEYVAULT_NAME
fi

# hard delete Log Analytics
$(az monitor log-analytics workspace delete -y --force true -g $ASB_CORE_RG -n la-${ASB_AKS_NAME})
$(az monitor log-analytics workspace delete -y --force true -g $ASB_HUB_RG -n $ASB_LA_HUB)

# delete the resource groups
az group delete -y --no-wait -g $ASB_CORE_RG
az group delete -y --no-wait -g $ASB_HUB_RG
az group delete -y --no-wait -g $ASB_SPOKE_RG

# delete from .kube/config
kubectl config delete-context $ASB_TEAM_NAME

echo ""
echo "check group delete:  az group list -o table | grep $ASB_TEAM_NAME"
