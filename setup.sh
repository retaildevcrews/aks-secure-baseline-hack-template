#!/bin/bash

if [ -z "$1" ]
then
  echo Team Name param missing
  exit 1
fi

if [ -z $(az ad signed-in-user show --query objectId -o tsv) ]
then
  echo Login to Azure first
  exit 1
fi

# change to the proper directory
cd $(dirname $0)

export ASB_TEAM_NAME=$1

# location
ASB_LOCATION=eastus2
ASB_GEO_LOCATION=centralus

# github info for flux
export ASB_GIT_REPO=$(git remote -v | cut -f 2 | cut -f 1 -d " " | head -n 1)
export ASB_GIT_BRANCH=$ASB_TEAM_NAME
export ASB_GIT_PATH=gitops

if [ -z "$ASB_GIT_REPO" ]
then
  echo Please cd to an ASB git repo
  exit 1
fi

# set domain name
export ASB_DNS_ZONE=aks-sb.com
export ASB_TLD=${ASB_TEAM_NAME}.${ASB_DNS_ZONE}

# export shared cert names
export ASB_CERT_KV_NAME=kv-tld
export ASB_CERT_NAME=aks-sb

# resource group names
export ASB_CORE_RG=rg-${ASB_TEAM_NAME}-core
export ASB_HUB_RG=rg-${ASB_TEAM_NAME}-networking-hubs
export ASB_SPOKE_RG=rg-${ASB_TEAM_NAME}-networking-spokes

# export AAD env vars
export ASB_TENANTID_K8SRBAC=$(az account show --query tenantId -o tsv)
export ASB_AADOBJECTNAME_GROUP_CLUSTERADMIN=cluster-admins-$ASB_TEAM_NAME

# create AAD cluster admin group
export ASB_AADOBJECTID_GROUP_CLUSTERADMIN=$(az ad group create --display-name $ASB_AADOBJECTNAME_GROUP_CLUSTERADMIN --mail-nickname $ASB_AADOBJECTNAME_GROUP_CLUSTERADMIN --description "Principals in this group are cluster admins on the cluster." --query objectId -o tsv)

# add current user to cluster admin group
# you can ignore the exists error
az ad group member add -g $ASB_AADOBJECTID_GROUP_CLUSTERADMIN --member-id $(az ad signed-in-user show --query objectId -o tsv)

# get *.onmicrosoft.com domain
export ASB_TENANTDOMAIN_K8SRBAC=$(az ad signed-in-user show --query 'userPrincipalName' -o tsv | cut -d '@' -f 2 | sed 's/\"//')

set -e

# create the resource groups
az group create -n $ASB_HUB_RG -l $ASB_LOCATION
az group create -n $ASB_SPOKE_RG -l $ASB_LOCATION
az group create -n $ASB_CORE_RG -l $ASB_LOCATION

# save env vars
./saveenv.sh -y

# deploy the network
az deployment group create -g $ASB_HUB_RG -f networking/hub-default.json -p location=${ASB_LOCATION}
export ASB_RESOURCEID_VNET_HUB=$(az deployment group show -g $ASB_HUB_RG -n hub-default --query properties.outputs.hubVnetId.value -o tsv)

az deployment group create -g $ASB_SPOKE_RG -f networking/spoke-BU0001A0008.json -p location=${ASB_LOCATION} hubVnetResourceId="${ASB_RESOURCEID_VNET_HUB}"
export ASB_RESOURCEID_SUBNET_NODEPOOLS=$(az deployment group show -g $ASB_SPOKE_RG -n spoke-BU0001A0008 --query properties.outputs.nodepoolSubnetResourceIds.value -o tsv)

az deployment group create -g $ASB_HUB_RG -f networking/hub-regionA.json -p location=${ASB_LOCATION} nodepoolSubnetResourceIds="['${ASB_RESOURCEID_SUBNET_NODEPOOLS}']"
export ASB_RESOURCEID_VNET_CLUSTERSPOKE=$(az deployment group show -g $ASB_SPOKE_RG -n spoke-BU0001A0008 --query properties.outputs.clusterVnetResourceId.value -o tsv)

# create ARM template
rm -f cluster-${ASB_TEAM_NAME}.json
# file contains '$schema'
cat templates/cluster-stamp.json | envsubst '$ASB_TEAM_NAME,$ASB_DNS_ZONE,$ASB_TLD' > cluster-${ASB_TEAM_NAME}.json

# grant executer permission to the key vault
az keyvault set-policy --certificate-permissions list get --object-id $(az ad signed-in-user show --query objectId -o tsv) -n $ASB_CERT_KV_NAME -g TLD
az keyvault set-policy --secret-permissions list get --object-id $(az ad signed-in-user show --query objectId -o tsv) -n $ASB_CERT_KV_NAME -g TLD

# create AKS
az deployment group create -g $ASB_CORE_RG \
  -f  cluster-${ASB_TEAM_NAME}.json \
  -p  location=${ASB_LOCATION} \
      geoRedundancyLocation=${ASB_GEO_LOCATION} \
      asbTeamName=${ASB_TEAM_NAME} \
      targetVnetResourceId=${ASB_RESOURCEID_VNET_CLUSTERSPOKE} \
      clusterAdminAadGroupObjectId=${ASB_AADOBJECTID_GROUP_CLUSTERADMIN} \
      k8sControlPlaneAuthorizationTenantId=${ASB_TENANTID_K8SRBAC} \
      appGatewayListenerCertificate=$(az keyvault secret show --vault-name $ASB_CERT_KV_NAME -n $ASB_CERT_NAME --query "value" -o tsv | tr -d '\n') \
      aksIngressControllerCertificate=$(az keyvault certificate show --vault-name $ASB_CERT_KV_NAME -n $ASB_CERT_NAME --query "cer" -o tsv | base64 | tr -d '\n')

# Remove user's permissions from shared keyvault. It is no longer needed after this step.
az keyvault delete-policy --object-id $(az ad signed-in-user show --query objectId -o tsv) -n $ASB_CERT_KV_NAME

# get cluster name
export ASB_AKS_CLUSTER_NAME=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksClusterName.value -o tsv)

# Get the public IP of our App gateway
export ASB_AKS_PIP=$(az network public-ip show -g $ASB_SPOKE_RG --name pip-BU0001A0008-00 --query ipAddress -o tsv)

# Add "A" record for the app gateway IP to the public DNS Zone
az network dns record-set a add-record -a $ASB_AKS_PIP -n $ASB_TEAM_NAME -g TLD -z aks-sb.com

# Get the AKS Ingress Controller Managed Identity details.
export ASB_TRAEFIK_USER_ASSIGNED_IDENTITY_RESOURCE_ID=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksIngressControllerPodManagedIdentityResourceId.value -o tsv)
export ASB_TRAEFIK_USER_ASSIGNED_IDENTITY_CLIENT_ID=$(az deployment group show -g $ASB_CORE_RG -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksIngressControllerPodManagedIdentityClientId.value -o tsv)
export ASB_POD_MI_ID=$(az identity show -n podmi-ingress-controller -g $ASB_CORE_RG --query principalId -o tsv)

az keyvault set-policy --certificate-permissions get --object-id $ASB_POD_MI_ID -n $ASB_CERT_KV_NAME
az keyvault set-policy --secret-permissions get --object-id $ASB_POD_MI_ID -n $ASB_CERT_KV_NAME

# config traefik
rm -f gitops/ingress/02-traefik-config.yaml
cat templates/traefik-config.yaml | envsubst  > gitops/ingress/02-traefik-config.yaml
rm -f gitops/ngsa/ngsa-ingress.yaml
cat templates/ngsa-ingress.yaml | envsubst  > gitops/ngsa/ngsa-ingress.yaml

# update flux.yaml
rm -f flux.yaml
cat templates/flux.yaml | envsubst  > flux.yaml

# save env vars
./saveenv.sh -y
