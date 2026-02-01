## Pipeline-21: Deploy Java app to AKS using Azure DevOps, Maven, SonarQube, Docker, ACR , Trivy , helm charts and enable HPA auto scaling implementing Blue-Green Deployment and Infrastructure also be created by Azure DevOps Pipeline. 

### ARCHITECTURE DIAGRAM
<img width="1360" height="786" alt="image" src="https://github.com/user-attachments/assets/8537ae76-b47a-4594-a043-dcc8e00936b8" />

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

## APPLICATION PIPELINE
- Navigate to your Github account and fork this repo https://github.com/luckysuie/spring-boot-shopping-cart
- Navigate to repos in the same project and import the above forked Repo to our Azure DevOps
- Now start writing pipeline for the below stages

### Pipeline Overview
- Trigger: Runs automatically on every push to the master branch.
- Agent: Uses Microsoft-hosted agent ubuntu-latest.
### Deployment Strategy: Blue/Green deployment using Helm:
- Blue owns the Kubernetes Service (the stable endpoint).
- Green is deployed in parallel without owning the Service.
- After Green is healthy, traffic is switched by updating the Service selector via Helm values.
________________________________________
### Required Azure Resources & Prerequisites
- Before running the pipeline, ensure the following exist:
- Azure Resources
  - Resource Group: rg-aks-acr-demo
  - AKS Cluster: aks-single-node-demo
  - ACR Registry: acruniquedemo12345
    - Login server: acruniquedemo12345.azurecr.io
Azure DevOps Service Connections
- Azure Resource Manager service connection for Azure + ACR + AKS access
  - Name used in pipeline: luckyspnconnection
  - SonarCloud service connection
  - Name used in pipeline: sonarcloud-sc
- Repo Prerequisites
    - Maven project must produce a JAR under target/
    - Dockerfile expects the JAR inside target/ (example: COPY target/*.jar ...)
    - Helm chart available at: helm/shopping-cart
________________________________________
### Variables Used
- The pipeline is parameterized using variables for:
    - Azure service connection, AKS, ACR, Resource Group
        - SonarCloud org + project keys
        - Docker image repository and tag (tag uses Build ID)
        - Helm namespace, chart path, and release names for Blue/Green
________________________________________
## Stages Explained
### Stage 1: BuildAndScan (Maven Build + SonarCloud)
- Purpose:
    - Prepares SonarCloud analysis
    - Builds the Java app using Maven (skips tests)
    - Publishes the target/ folder as a pipeline artifact
    - Runs SonarCloud scan and checks the quality gate
### Key outputs:
- Maven-generated JAR in target/
- SonarCloud Quality Gate result
________________________________________
### Stage 2: BuildPush (Docker Build & Push to ACR)
- Purpose:
- Downloads the target/ artifact from Stage 1
- Copies the JAR back into a local target/ folder for Docker build context
- Logs into ACR using Azure CLI
- Builds and pushes Docker image to ACR
    - Image naming format:
    - acruniquedemo12345.azurecr.io/shopcart:<BuildId>
________________________________________
### Stage 3: Trivy (Remote Scan from ACR)
- Purpose:
    - Logs into ACR
    - Installs Trivy on the build agent
    - Scans the pushed image remotely from ACR
- Scan focus:
    - Severity levels: HIGH, CRITICAL
    - Ignores unfixed vulnerabilities
    - Does not fail the pipeline (scan is reporting-focused)
________________________________________
### Stage 4: Deploy (AKS Deploy with Helm + Blue/Green)
- Purpose:
    - Fetches AKS credentials using Azure CLI
    - Ensures Kubernetes namespace exists
    - Deploys/updates Blue release (creates Service)
    - Deploys/updates Green release (does not create Service)
    - Waits for Green deployment readiness
- Switches traffic from Blue to Green by updating Service selector
- Displays HPA status
- Result:
    - Traffic is moved to the new Green deployment with minimal downtime.
________________________________________
### Kubernetes Objects Expected
- In the namespace shopping-cart, the chart typically creates:
    - Deployments: shopping-cart-blue, shopping-cart-green
    - Service: shopping-cart-svc (owned by Blue release)
    - Optional: HPA (Horizontal Pod Autoscaler), if configured in chart

### Result 
- Browse the publicip of loadbalancer to get the website

### Azure DevOps Pipeline
<img width="1559" height="905" alt="image" src="https://github.com/user-attachments/assets/753d4a21-81dd-41b7-81b6-a6fc2ea0245c" />

### Website
<img width="1878" height="925" alt="Screenshot 2026-02-01 152257" src="https://github.com/user-attachments/assets/2a2a8192-737c-4b58-b425-563459af58fa" />

