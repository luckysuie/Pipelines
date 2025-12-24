 # Pipeline-20: Build a CI/CD pipeline for a .NET web application using Azure DevOps with Stages with Blue -Green Deployment Strategy. Use Terraform configuration for creating App Services in Azure.

### Phase 1 : Infra(Azure Web app by Terraform)
- Create a three azure app services in three different resouces groups with environments like DEV staging and prod and prod must have slots for BLUE GREEN deployment strategy by Terraform (IAC)
- Steps:
a. Terraform should be installed locally and be working
b. Az CLI should be installed locally and login to your Azure account
c. Create a folder named project-3 in local and open it with Visual studio code
    1. create two files named dev-staging.tf and production.tf
    Link for dev and staging: https://github.com/luckysuie/Pipelines/blob/main/Pipeline-20/dev-staging.tf
    Link for production: https://github.com/luckysuie/Pipelines/blob/main/Pipeline-20/production.tf
    2. open new terminal inside the visual studio code itself and run terrraform commands
    ```bash
    terraform init
    terraform validate
    terraform plan
    terraform apply --auto-approve
    ```


