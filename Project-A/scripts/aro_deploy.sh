#!/bin/bash

# https://docs.microsoft.com/en-us/azure/openshift/tutorial-create-cluster

LOCATION=eastus
az vm list-usage -l $LOCATION \
--query "[?contains(name.value, 'standardDSv3Family')]" \
-o table


# # Specify sub id
# az account set --subscription <SUBSCRIPTION ID>


# Register the Microsoft.RedHatOpenShift resource provider:
az provider register -n Microsoft.RedHatOpenShift --wait



# Register the Microsoft.Compute resource provider
az provider register -n Microsoft.Compute --wait



# Register the Microsoft.Storage resource provider:
az provider register -n Microsoft.Storage --wait



# Register the Microsoft.Authorization resource provider:
az provider register -n Microsoft.Authorization --wait

az feature register --namespace Microsoft.RedHatOpenShift --name preview





# Create a virtual network containing two empty subnets
# Set the following variables in the shell environment in which you will execute the az commands.
# Console
export LOCATION=eastus                 # the location of your cluster
export RESOURCEGROUP=aro-rg            # the name of the resource group where you want to create your cluster
export CLUSTER=cluster                 # the name of your cluster


export LOCATION=eastus
export RESOURCEGROUP=aro-rg
export CLUSTER=cluster


# Create rg
az group create \
  --name $RESOURCEGROUP \
  --location $LOCATION


# Create a virtual network
az network vnet create \
   --resource-group $RESOURCEGROUP \
   --name aro-vnet \
   --address-prefixes 10.0.0.0/22


# Add an empty subnet for master nodes
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name master-subnet \
  --address-prefixes 10.0.0.0/23 \
  --service-endpoints Microsoft.ContainerRegistry


# Add an empty subnet to worker nodes
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name worker-subnet \
  --address-prefixes 10.0.2.0/23 \
  --service-endpoints Microsoft.ContainerRegistry






# Disable subnet private endpoint policies
az network vnet subnet update \
  --name master-subnet \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --disable-private-link-service-network-policies true




# Create the cluster
az aro create \
  --resource-group $RESOURCEGROUP \
  --name $CLUSTER \
  --vnet aro-vnet \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet







# Connect to the cluster
# You can log into the cluster using the kubeadmin user. Run the following command to find the password for the kubeadmin user.
az aro list-credentials \
  --name $CLUSTER \
  --resource-group $RESOURCEGROUP





# ou can find the cluster console URL by running the following command, which will look like https://console-openshift-console.apps.<random>.<region>.aroapp.io/.
 az aro show \
    --name $CLUSTER \
    --resource-group $RESOURCEGROUP \
    --query "consoleProfile.url" -o tsv




# Then Install openshift
cd ~
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

mkdir openshift
tar -zxvf openshift-client-linux.tar.gz -C openshift
echo 'export PATH=$PATH:~/openshift' >> ~/.bashrc && source ~/.bashrc



# Connect using the OpenShift CLI
# Retrieve the API server's address.
# Connect to the API Server
apiServer=$(az aro show -g $RESOURCEGROUP -n $CLUSTER --query apiserverProfile.url -o tsv)



# Login to the OpenShift cluster's API server using the following command. Replace <kubeadmin password> with the password you just retrieved.
oc login $apiServer -u kubeadmin -p <kubeadmin password>




# Delete Cluster
az aro delete --resource-group $RESOURCEGROUP --name $CLUSTER
# You'll then be prompted to confirm if you want to delete the cluster. 
# After you confirm with y, it will take several minutes to delete the cluster.
# When the command finishes, the entire resource group and all resources inside it, including the cluster, will be deleted.
































