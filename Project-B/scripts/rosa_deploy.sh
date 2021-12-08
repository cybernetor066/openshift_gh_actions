#!/bin/bash


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
