# Pipeline 10: Automating AKS Infrastructure Deployment using Terraform modules and Upgrading the version via Azure DevOps Pipeline
------------
## Steps: 
--------
1. Navigate to your Azure DevOps Account and create a new project named AKS-project
2. Navigate to repos, Click on Import and import the below repo
https://dev.azure.com/luckyashu1856/_git/aksssssss
3. Create an app registration using cloud shell by below
```bash
az ad sp create-for-rbac \
  --name "lucky1234" \
  --role Contributor \
  --scopes /subscriptions/yoursubscriptionid
```
Note down the output like below
```bash
{
  "appId": "yourappId",
  "displayName": "lucky1234",
  "password": "yourapppassword",
  "tenant": "yourtenantID"
}
```
4. Assigning Owner role to above App registration using portal
steps:
-------
- Navigate to subscription and click on subscription
- On the left blade select  IAM --> + Add Role assignment
- Select Privileged administrator roles-->owner-->next
- After clicking select members then in the right side search bar type lucky1234-->select-->next
- After that Conditions will open in that 
What user can do : Allow user to assign all roles except privileged administrator roles Owner, UAA, RBAC (Recommended) 
- check above
- Review and assign

5. create a resource group with name **demo-aks** in Canada central Region
6. create a storage account in the above resource group named **backendstorage143**
7. Navigate to storage account (backendstorage143) create a container named **lucky**
8. Navigate to subscriptions in the portal and note down your subscriptionid
9. Navigate to Microsoftentra ID--->App registrations-->lucky1234 and Note down the object ID
10. Navigate to your Azure DevOps project and Repos--> versions.tf
- Change the subscriptionId
11. Navigate to terraform.tfvars--> at the end of file
- change subscriptionId and objectID
12. create an Azurerm service connection Project settings-->service connections--> New service Connection--> Azure Resource Manager

- Identity Type: App registration or managed identity(manual)
- credential: secret
- Environment: Azure cloud
- scope level: subscription
- subscription ID: you-subscription-ID
- subscription name: your subscription name
- application(client ID): your applicationclientID
- Directory(tenant)ID: your directory TenantID
- credential-->service principal key
- client secret : password
- service connection Name: lucky-spn-connec

10. Navigate to Pipelines-->Environments
- click on Prod (which is already there) if not create prod
- Then navigate to Approvals and checks
- click on + icon and search for approvals
- type your Gmail ID and click create

11. Navigate to pipelines and start running the pipeline
- It should run automatically upto terraform validate without errors
- For Terraform apply stage it will ask approval to Apply the Insfrastructure then
- For Terraform destroy stage it will ask approval to destroy the Insfrastructure 
