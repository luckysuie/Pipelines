## Pipeline-20: Build a CI/CD pipeline for a .NET web application using Azure DevOps with Stages with Blue -Green Deployment Strategy. Use Terraform configuration for creating App Services in Azure.

### Phase 0: Uderstanding Stages/Environments and Slots
 - There are TWO different concepts that people mix up:
   - 🔹 Stages (Dev / Staging / Prod) → WHERE you deploy
   - 🔹 Slots (Blue / Green) → HOW you deploy
- If you remember this one line, confusion ends.

```bash
+---------------------+      +-----------------------+      +------------------------+
|   DEV Environment   |      |  STAGING Environment  |      |    PROD Environment    |
|                     |      |                       |      |                        |
|  App Service (Dev)  |      | App Service (Staging) |      |  App Service (Prod)    |
|                     |      |                       |      |                        |
|  • No slots         |      | • No slots (simple)   |      |  • Uses deployment     |
|  • Fast iteration  |      | • Pre-prod testing    |      |    slots               |
|                     |      |                       |      |                        |
+---------------------+      +-----------------------+      +------------------------+
```
- As per requirement if we want we can put slots in DEV and STAGING as well
#### BLUE GREEN inside the App service
```bash                    
                    PROD App Service
        +------------------------------------------------+
        |                                                |
        |  +------------------------------------------+  |
Users ──▶|  | Production Slot (BLUE - Live Traffic)   |  |
        |  +------------------------------------------+  |
        |                    ▲                          |
        |                    |  Slot Swap               |
        |                    ▼                          |
        |  +------------------------------------------+  |
        |  | Staging Slot (GREEN - New Version)       |  |
        |  +------------------------------------------+  |
        |                                                |
        +------------------------------------------------+
```
### Phase 1 : Infra(Dotnet Web app by Terraform)
- Create a three azure app services in three different resouces groups with environments like DEV staging and prod and prod must have slots for BLUE GREEN deployment strategy by Terraform (IAC)
 - Steps:
   - a. Terraform should be installed locally and be working
   - b. Az CLI should be installed locally and login to your Azure account
   - c. Create a folder named project-3 or any other in local and open it with Visual studio code
    1. create two files named dev-staging.tf and production.tf
       - Link for dev and staging: https://github.com/luckysuie/Pipelines/blob/main/Pipeline-20/dev-staging.tf
       - Link for production: https://github.com/luckysuie/Pipelines/blob/main/Pipeline-20/production.tf
    2. open new terminal inside the visual studio code itself and run terrraform commands
    ```bash
    terraform init
    terraform validate
    terraform plan
    terraform apply --auto-approve
    ```
    3. You dotnet webapps will be created succesfully. Check your Portal and make sure all webapps are running by browsing it. 

### Service connection pre-requisite:
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

### Project Repo and service connection setup:
- Navigate to your Azure Devops Portal and create a new project named Dotnetwebapp
- Navigate to Repos and on top drop down you will see Import repo select it and import this github repo : https://github.com/luckysuie/dotnetwebapp
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
  - service connection Name: luckyspnconnec       #you can give any name that is upto you
