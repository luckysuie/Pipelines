# Pipeline 13 : Infrastructure as Code (IaC) with Azure DevOps and Terraform

Automate infrastructure provisioning using Terraform and Azure DevOps.
Write Terraform scripts to provision Azure resources (e.g., VMs, VNet, Storage Accounts).
Set up a Build Pipeline to:
	Validate and plan Terraform changes.
Set up a Release Pipeline to:
	Apply Terraform changes to Azure.
	Use environments for staging and production.
	Store Terraform state files in Azure Storage.
	Use Azure Policy to enforce compliance.

Steps:
----------------
1. Create a folder in local named TerrafomProject and in that create another folder named project3
2. Open project3 in visual studio code and create the below files
	1. main.tf
	2. backend.conf
	3. terraform.tfvars
	4. variables.tf
3. Navigate to portal and create a storage account and container in it
4. Give the required storage account details in the backend.conf file so that it will store the tfstate file
5. Things to put in main.tf
	1. Your cloud provider along with subscription
	2. Infrastructure as a code which are required for the creation of a Ubuntu Virtual machine
6. Things to put in backend.tf
	1. Storage account details which stores the tfstate file
7. Things to put in the terraform.tfvars
	1. input variables which are names that are required for the main and backend
8. Things to put in the variables.tf
	1. defining variables type that are required for main and backend
Testing in Local: 
	1. open new terminal and run Terraform commands
		terraform init
		terraform validate
		terraform plan
		terraform apply
output: It should create the Ubuntu virtual machine in the portal

pre-requisite
----------------
1. create a project named BootcampProject-3 in the Azure DevOps portal
2. create a repo named lucky 
3. push your local folder(project3) to your Azure DevOps repo(lucky)
