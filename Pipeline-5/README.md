# Pipeline 5: Deploying a .NET application into AKS using Docker, ACR, Trivy with Azure DevOps pipeline
## Steps:
------
1. Navigate to your Azure DevOps account and create a private project with name SecureNetToAKS
2. Navigate to repos and import this repo : https://github.com/luckysuie/asp.net
3. Create an ACR in Azure portal or using Azure cloud shell and enable username and password
```bash
az acr create --resource-group demo11 --name luckyregistry --sku Basic
```
5. create an AKS cluster with single node Azure cloud shell or Portal
```bash
az aks create   --resource-group demo11   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys
```
7. create an ACR secret by using below. The purpose of this is pulls the image from acr to deployment
```bash
kubectl create secret docker-registry acr-secret \
  --docker-server=luckyregistry.azurecr.io \
  --docker-username=luckyregistry \
  --docker-password=youregistrypassword \
  --docker-email=example@gmail.com 
```
5. create an app service registration in EntraID and note down all the values
```bash
az ad sp create-for-rbac \
  --name "test" \
  --role Contributor \
  --scopes /subscriptions/yoursubscriptionid
```
Imp: Note down the output whatever came like below
```bash
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "tf-spn-devops",
  "password": "generated-client-secret",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```
6. Create an ACR service connection and note down its name
Project settings-->service connections--> New service Connection--> 
Docker Registry--> Azure container REgistry--> your subscription-->your ACR -->ACR Name-->verify and save

7. create an Azurerm service connection note down its name
Project settings-->service connections--> New service Connection--> Azure Resource Manager
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
- service connection Name: provide any name of the service connection

8. Navigate to pipelines and start writing pipeline for CI and CD

### Continuous Integration CI
- write a Yaml code for Docker Building Docker Image and pushing it into ACR
- write a Yaml Task for Logging into ACR and pulling the storedimage
- write a task with inline script for downloading Trivy for scanning the pulled Image and provide an report with Table format
- write a yaml task to store the store the report as an artifact

### Continuous Deployment CD
- wrirte a Yaml task for AKs Get credentials
- write a yaml task for deploying the image to aks

![Screenshot 2025-06-22 184442](https://github.com/user-attachments/assets/0649d21c-89c4-4e89-8f23-bf48c15a14cf)
