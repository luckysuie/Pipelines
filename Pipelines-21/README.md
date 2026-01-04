## Pipeline-21: Deploy Java app to AKS using Azure DevOps, Maven, SonarQube, Docker, ACR , Trivy , helm charts and enable HPA auto scaling implementing Blue-Green Deployment and Infrastructure also be created by Azure DevOps Pipeline. 
- Here we are implementing two pipelines
    1. Infra Pipleine for AKS and ACR by Terraform
    2. Application Pipeline
### Infra Pipeline
- write Terrraform code for the creation of aks and ACR using terraform and store it in GitHub
- write backend storage account bash file as well and store it in Github
- GitHub Repo: https://github.com/luckysuie/aks-acr (U can use this repo as well)

### Pipeline: 
 - Navigate to your Azure DevOps portal and create a project with your convinent name
 - Navigate to repos and import your GitHub Repo https://github.com/luckysuie/aks-acr
 - Navigate to Pipelines and start writing Yaml Pipeline for your Infra creation
### Statges
- Storage Account creation
- Terrafom
      - Terraform Installation
      - Terraform Init
      - Terraforn validate
      - Terraform apply
### Pipeline Link: https://github.com/luckysuie/Pipelines/blob/main/Pipelines-21/infrapipeline.yaml
## SUccesfull Infra Creation
<img width="1539" height="786" alt="image" src="https://github.com/user-attachments/assets/b8ae865a-6741-43bd-87f2-d5debcc45283" />

