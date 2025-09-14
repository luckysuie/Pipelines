# Pipeline-15:Build a CI/CD pipeline for a .NET web application using Azure DevOps with Stages
Steps:
--------------
1. Navigate to your Azure DevOps account and create a project named Bootcamp1
2. Navigate to Repositories and click on import repo
GitHubrepo: https://github.com/luckysuie/dotnetwebapp

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
Click on the "Role assignments" tab
- Add Role Assignment
    - Click the "+ Add" button
    - Select "Add role assignment" from the dropdown
Configure Role Assignment
Role: In the Role tab, search and select "Owner"
Click "Next" Assign Access to User
In the Members tab:
Scope: Leave as default (User, group, or service principal)
Click "+ Select members"
Type lucky in the search bar
Select the matching user account
Click "Select" • Click "Next"
Set Conditions
In the Conditions (preview) tab:
Choose the recommended condition shown (typically for least privilege or conditional access context)
Review what the condition does
Click "Next"
Review and Assign
Review all your selections
Click "Review + assign"


create an Azurerm service connection Project settings-->service connections--> New service Connection--> Azure Resource Manager
Identity Type: App registration or managed identity(manual)
credential: secret
Environment: Azure cloud
scope level: subscription
subscription ID: you-subscription-ID
subscription name: your subscription name
application(client ID): your applicationclientID
Directory(tenant)ID: your directory TenantID
credential-->service principal key
client secret : password
service connection Name: luckyappconnec       #you can give any name that is upto you


Pipeline:
------------
Navigate to Pipelines>Azure Repos Git
Select a repository: select your repo
Configure your pipeline: Starter pipeline

Now start writing pipeline for the below
---------

CI (Continuous Integration)
• Install .NET SDK (UseDotNet)
• Restore NuGet packages
• Build the solution
• Run unit tests
• Publish the web project
• Create a ZIP package
• Publish pipeline artifact

CD (Continuous Deployment)
• Download the artifact from the build
• Deploy to Azure App Service (Dev)
• Deploy to Azure App Service (Staging)
• Deploy to Azure App Service (Production)
