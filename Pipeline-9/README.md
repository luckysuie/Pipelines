# Pipeline 9: Depoloying a .net application to AKS using ACR, Docker via Azure DevOps Yaml pipeline
## steps:
1. Navigate to Azure DevOps portal create a project named pipeline 9
2. Navigate to Repos and import this repo https://dev.azure.com/luckyashu1856/luckyyyy/_git/AzureAspWebApp-c266
3. Navigate to cloud shell in portal and create below
- create a resource group
```bash
az group create --name demo11 --location canadacentral
```
- Create an Azure container Registry

```bash
az acr create --resource-group demo11 --name luckyregistry --sku Basic
```
- create an AKS cluster with single node Azure cloud shell or Portal

```bash
az aks create   --resource-group demo11   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys

```
- Retrieve AKS cluster credentials and merges them into your local kubeconfig
```bash
az aks get-credentials --name lucky-aks-cluster11 --resouce-group demo11
```

- Create an secret purpose: helps in pulling image from ACR to AKS
```bash
kubectl create secret docker-registry acr-secret \
  --docker-server=luckyregistry.azurecr.io \
  --docker-username=luckyregistry \
  --docker-password=yourregistrypasword \
  --docker-email=luckyashu1856@gmail.com
```

4. Create an ACR service connection and note down its name Project settings-->service connections--> New service Connection--> Docker Registry--> Azure container REgistry--> your subscription-->your ACR -->ACR Name-->verify and save

5. create an Azurerm service connection note down its name Project settings-->service connections--> New service Connection--> Azure Resource Manager---> use service principal

6. Now start writing pipeline for

CI Continuous Integration
------
Stage 
- Install Nuget
- Nuget Restore
- Build
- publish artifact

CD Continuous Integration
------
Stage
- Buildandpush to docker
- Login to acr
- Deploy to AKS

Testings
--------
1. Navigate to cloud Shell and type
```bash
kubectl get all
````
- Output: You should see everything Running along with with external ip
- Browse the Ip you will see the below page

![Screenshot 2025-06-28 115329](https://github.com/user-attachments/assets/8908c8f5-5fe0-4b63-9ca7-9c5fae6cd12b)
