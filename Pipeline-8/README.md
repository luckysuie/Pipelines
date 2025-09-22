# Pipeline-8: Deploying a java springboot application to aks using Maven, SonarQube, Docker, ACR, Trivy and Azure Kubernetes by Azure DevOps pipeline
## steps:
----------------
1. Navigate to Azure DevOps and create a new project named pipeline-8
2. Navigate to repos
Click on Import and import this repo https://github.com/bkrrajmali/enahanced-petclinc-springboot
## Architecture Diagram
<img width="1642" height="582" alt="image" src="https://github.com/user-attachments/assets/beb6274d-436a-4a05-a256-915b9a98914d" />
3. Open sonarcloud.io and login into your account using GitHub
4. Create an organization named JavaOrganization and create a project named javanalysis in that organization
5. Navigate to my account--> security-->Generate Token
Note down the below
- Token
- project name
- project key
- organization key
- organization name

6. Navigate to Azure DevOps and move project settings and create a service connection for sonar cloud
7. Navigate to Azure DevOps and move project settings and create a service connection using Azure resource Manager

8. Navigate to cloudshell in the Azure portal and create below
- Create resource group
```
az grp create --name lucky --location eastus
```
- Create an acr in that resource group
```
az acr create --resource-group lucky --name demorg1 --sku Basic
```
Note: after creation enable username and password by navigating to access keys in the ACR

- Create an AKS cluster using below
```
az aks create   --resource-group lucky   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys
```
- create a secret. purpose: Connection between ACR and AKS
```
kubectl create secret docker-registry acr-auth \
  --docker-server=demorg1.azurecr.io \
  --docker-username=demorg1 \
  --docker-password=youacrpassword \
  --docker-email=anydummygmail
```
8. Navigate to Azure DevOps and move project settings and create a service connection for ACR
9. Now start writing the pipeline for

## CI Continous Integration
Stage: Build, Analyze, and Push
- Java Installation
- Sonar preparation
- Maven Goals  clean package sonar:sonar
- publishing the sonar report
- Docker Building and pushing

Stage: Trivy scan with Report
- Pulling image
- Installing and scannng Trivy
- pubishing Trivy report to contaienr

## CD Continous Deployment 
 Stage: Deploying to Kubernetes
- Deploy to aks

## Output
- Trivy Report
![Screenshot 2025-06-26 105829](https://github.com/user-attachments/assets/6cc70c54-9188-448b-bf96-c48933464159)

- Sonar Analysis
![Screenshot 2025-06-26 105629](https://github.com/user-attachments/assets/ab92f299-16cc-42f6-8e02-d8f617c9d21d)

- web app
![Screenshot 2025-06-26 105514](https://github.com/user-attachments/assets/7143fc51-6854-46a4-bed2-5534268882a7)
