 # Pipeline-20: Build a CI/CD pipeline for a .NET web application using Azure DevOps with Stages with Blue -Green Deployment Strategy. Use Terraform configuration for creating App Services in Azure.



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


