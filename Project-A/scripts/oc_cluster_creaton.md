
# *****************************************************************
# *****************************************************************
# *****************************************************************
# DEPLOYING OPENSHIFT IN AZURE     (ARO)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash


# Openshift configuration 

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


















<!--  -->
<!--  -->
<!--  -->
<!-- Creating Openshift on AWS  (ROSA) -->
https://www.rosaworkshop.io/rosa/1-account_setup/
Enable openshift on aws in the aws console

<!-- On your local machine do -->
wget https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
tar xvf rosa-linux.tar.gz
sudo mv rosa /usr/local/bin


<!-- Make sure aws-cli is installed -->


<!-- Download openshift client -->
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
<!-- Or -->
rosa download oc

tar xvf openshift-client-linux.tar.gz
sudo mv oc /usr/local/bin




rosa login
<!-- Then generate a login token here -->
https://console.redhat.com/openshift/token/rosa




<!-- Describe a service quota -->
aws service-quotas get-service-quota \
    --service-code ec2 \
    --quota-code L-1216C47A


<!-- To request a service quota increase
Open the Service Quotas console at https://console.aws.amazon.com/servicequotas/
In the navigation pane, choose AWS services.
Choose a service from the list, or type the name of the service in the search box.
If the quota is adjustable, you can choose its button or its name, and then choose Request quota increase.
For Change quota value, enter the new value. The new value must be greater than the current value.

Choose Request. After the request is resolved, the Applied quota value for the quota is set to the new value.
To view any pending or recently resolved requests, choose Dashboard from the navigation pane. For pending requests, choose the status of the request to open the request receipt. The initial status of a request is Pending. After the status changes to Quota requested, you'll see the case number with AWS Support. Choose the case number to open the ticket for your request.
 -->



<!-- Create account roles# -->
<!-- If this is the first time you are deploying ROSA in this account and have not yet created the account roles then enable ROSA to create JSON files for account-wide roles and policies, including Operator policies. -->

<!-- Run the following command to create the account-wide roles: -->
rosa create account-roles --mode auto --yes


<!-- Then create cluster -->
<!-- rosa create cluster --cluster-name <cluster-name> --sts --mode auto --yes -->
rosa create cluster --cluster-name cluster-01 --sts --mode auto --yes



<!-- Check installation status# -->
<!-- You can run the following command to check the detailed status of the cluster: -->

rosa describe cluster --cluster <cluster-name>

<!-- or you can run the following for an abridged view of the status: -->

rosa list clusters

<!-- You should notice the state change from “waiting” to “installing” to "ready". This will take about 40 minutes to run.
Once the state changes to “ready” your cluster is now installed. -->


<!-- To delete clusters -->
rosa delete cluster --cluster my-rosa-cluster
rosa logs uninstall -c my-rosa-cluster --watch




<!-- Obtain the Console URL# -->
<!-- To get the console URL run: -->
rosa describe cluster -c <cluster-name> | grep Console




<!-- Create an admin user for quick access# -->
rosa create admin --cluster=<cluster-name>

<!-- $ oc login https://api.my-rosa-cluster.abcd.p1.openshiftapps.com:6443 \
>    --username cluster-admin \
>    --password FWGYL-2mkJI-00000-00000 -->


<!-- Accessing the cluster via the web console -->
rosa describe cluster -c <cluster-name> | grep Console


<!-- We can confirm that we are now the user we logged in with by running oc whoami -->

$ oc whoami
rosa-user








<!-- Troubleshooting Error -->
Provisioning Error Code:    OCM3037
Provisioning Error Message: The required service-linked role for Elastic Load Balancers is missing. This is a manual prerequisite step. Verify that you have manually created the role according to the documentation, and try again.

<!-- Solution -->
<!-- Create a role called -->
AWSServiceRoleForElasticLoadBalancing 





<!-- Troubleshooting Error -->
Provisioning Error Code:    OCM3018
Provisioning Error Message: No worker nodes could be created. This usually happens when your cluster is attempting to use roles from a previous installation attempt. If you have previously installed a cluster in this AWS account, be sure to delete all old unused roles before retrying installation. Otherwise, verify that the trust relationship for your "openshift-machine-api-aws-cloud-credentials" role references the OIDC provider for the current cluster id, and try again.


<!-- Solution -->
<!-- Removing roles -->
rosa list account-roles
rosa delete account-roles -p ManagedOpenShift --mode auto --yes


<!-- To delete clusters -->
rosa delete cluster --cluster my-rosa-cluster
rosa logs uninstall -c my-rosa-cluster --watch

aws iam list-open-id-connect-providers

aws iam delete-open-id-connect-provider --open-id-connect-provider-arn <oidc_provider_arn> 


<!-- Request to increase quota to 100 value -->

