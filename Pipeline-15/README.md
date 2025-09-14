# Pipeline-15:Build a CI/CD pipeline for a .NET web application using Azure DevOps with Stages
## Architecture Diagram
<img width="1338" height="729" alt="image" src="https://github.com/user-attachments/assets/4d0cca85-6f70-4fe5-af9e-a6fb5b4b7b86" />

Steps:
--------------
1. Navigate to your Azure DevOps account and create a project named Bootcamp1
2. Navigate to Repositories and click on import repo
- GitHubrepo: https://github.com/luckysuie/dotnetwebapp

## Service connection setup:
--------
1. Navigate to portal
2. Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg: lucky
3. Navigate to lucky > top right secret > create a secret Now note down
```bash
Application (client) ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Object ID :xxxxxxxxxxxxxxxxxxxxxxxx
Directory (tenant) ID :xxxxxxxxxxxxxxxxxxxx
value : xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Secret ID: Xxxxxxxxxxxxxxxxxxxxxxxxx
subscription ID: Xxxxxxxxxxxxxxxxxxxxxxxx
```

3. Assigning Role to lucky
- Navigate to the Subscriptions in portal
- Open the IAM (Access Control) Blade
    - In the subscription panel, select "Access control (IAM)"
- Click on the "Role assignments" tab
- Add Role Assignment
  - Click the "+ Add" button
  - Select "Add role assignment" from the dropdown
- Configure Role Assignment
  - Role: In the Role tab, search and select "Owner"
  - Click "Next"
- Assign Access to User
  - In the Members tab:
  - Scope: Leave as default (User, group, or service principal)
  - Click "+ Select members"
  - Type lucky in the search bar
  - Select the matching user account
  - Click "Select"
•	Click "Next"
- Set Conditions
  - In the Conditions (preview) tab:
  - Choose the recommended condition shown (typically for least privilege or conditional access context)
  - Review what the condition does
  - Click "Next"
- Review and Assign
  - Review all your selections
  - Click "Review + assign"
  - Confirm the assignment once more if prompted


- create an Azurerm service connection Project settings-->service connections--> New service Connection--> Azure Resource Manager
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
  - service connection Name: luckyappconnec       #you can give any name that is upto you

## App services
1. Navigate to Portal
2. Create three resouce groups named rg-myapp-dev, rg-myapp-stg, rg-myapp-prd
3. Create three web apps(Azure App service) inside the resource groups named mywebapp-dev, mywebapp-stg, mywebapp-prd with Runtime stack of .net8
4. verify whether three are running or not

Pipeline:
------------
Navigate to Pipelines>Azure Repos Git
Select a repository: select your repo
Configure your pipeline: Starter pipeline

Now start writing pipeline for the below
---------

## CI (Continuous Integration)
- Install .NET SDK (UseDotNet)
- Restore NuGet packages
- Build the solution
- Run unit tests
- Publish the web project
- Create a ZIP package
- Publish pipeline artifact

## CD (Continuous Deployment)
- Download the artifact from the build
- Deploy to Azure App Service (Dev)
- Deploy to Azure App Service (Staging)
- Deploy to Azure App Service (Production)

## output
- Succesfull Pipeline
<img width="1554" height="819" alt="Screenshot 2025-09-14 085631" src="https://github.com/user-attachments/assets/fb03d19b-8695-45be-817e-826eef1b9d55" />

- Website
<img width="1889" height="958" alt="Screenshot 2025-09-14 085926" src="https://github.com/user-attachments/assets/74992043-8c1e-4298-8c8a-eca3b02d7e63" />

- Stages Monitoring(Dev, Staging. Prod)

<img width="1474" height="861" alt="Screenshot 2025-09-14 085816" src="https://github.com/user-attachments/assets/46ded056-c292-4bd4-af35-25dd9befafcd" />
<img width="1475" height="844" alt="Screenshot 2025-09-14 085756" src="https://github.com/user-attachments/assets/c87e89e6-f220-4e15-95f4-2741960382cc" />
<img width="1797" height="823" alt="Screenshot 2025-09-14 085721" src="https://github.com/user-attachments/assets/c6d2cc9d-a057-4e43-ad28-8ce1ab341911" />


