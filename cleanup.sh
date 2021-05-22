#!/bin/bash

# change to the proper directory
cd $(dirname $0)

set -e

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
export ASB_HUB_RG=rg-${ASB_TEAM_NAME}-networking-hubs
export ASB_SPOKE_RG=rg-${ASB_TEAM_NAME}-networking-spokes

export ASB_AADOBJECTNAME_GROUP_CLUSTERADMIN=cluster-admins-$ASB_TEAM_NAME
export ASB_AKS_CLUSTER_NAME=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksClusterName.value -o tsv)
export ASB_KEYVAULT_NAME=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.keyVaultName.value -o tsv)
export ASB_LA_HUB=$(az monitor log-analytics workspace list -g $ASB_HUB_RG --query [0].name -o tsv)

if [ -z "$ASB_AKS_CLUSTER_NAME" ]
then
  echo Unable to get AKS Cluster Name
  exit 1
fi

if [ -z "$ASB_KEYVAULT_NAME" ]
then
  echo Unable to get Key Vault Name
  exit 1
fi

# delete and purge the key vault
az keyvault delete -n $ASB_KEYVAULT_NAME
az keyvault purge -n $ASB_KEYVAULT_NAME

# hard delete Log Analytics
az monitor log-analytics workspace delete -y --force true -g $ASB_CORE_RG -n la-${ASB_AKS_CLUSTER_NAME}
az monitor log-analytics workspace delete -y --force true -g $ASB_HUB_RG -n $ASB_LA_HUB

# delete AAD group
az ad group delete -g $ASB_AADOBJECTNAME_GROUP_CLUSTERADMIN

# delete the resource groups
az group delete -y --no-wait -g $ASB_CORE_RG
az group delete -y --no-wait -g $ASB_HUB_RG
az group delete -y --no-wait -g $ASB_SPOKE_RG

echo "run az group list -o table | grep $ASB_TEAM_NAME to check progress"

# delete from .kube/config
### you can ignore any errors
kubectl config delete-context $ASB_TEAM_NAME
