# Pipeline 13: Infrastructure as Code (IaC) with Azure DevOps and Terraform
Automate infrastructure provisioning using Terraform and Azure DevOps.
Write Terraform scripts to provision Azure resources (e.g., VMs, VNet, Storage Accounts).
- Set up a Build Pipeline to:
	Validate and plan Terraform changes.
- Set up a Release Pipeline to:
	Apply Terraform changes to Azure.
	Use environments for staging and production.
	Store Terraform state files in Azure Storage.
	Use Azure Policy to enforce compliance.

## Architecture Diagram

<img width="1323" height="685" alt="Screenshot 2025-07-28 152654" src="https://github.com/user-attachments/assets/5c6edc00-6cd3-447c-b28d-4a3908c57221" />

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

commands:
------
```bash
cd project3  #if you are already here dont use this command
git init
git add .
git commit -m "Initial commit"
git remote add origin https://dev.azure.com/luckyashu1856/Boot%20camp%20-%203/_git/lucky
git branch -M main
git push -u origin main --force
Username: luckyashu1856
Password: <paste-your-PAT-here>
```
output: After pushing you will be seeing all your files in your Azure DevOps Repo

Pipeline using Classic Editor
---------
Continuous Integration
---------------
0. Enable classic editor organization settings>pipelines>settings>Disable creation of classic release pipelines and Disable creation of classic build pipelines. By on and off check whether its enabled or not
1. Navigate to pipelines>New pipeline>classic editor
2. check project name and your repository>continue>top right click Empty Job
  - Name: Terraformproject
	- agent pool: Azure Pipelines
  - agent specification : ubuntu-22.04
3. click on Agent Job 1 which is visible in the current UI
	- Name : Agent Set
	- agent pool: Azure pipelines
	- agent specification: ubuuntu-22.04
4. click on the +icon which is shown in Agent set which you created then you will be navigated to add tasks
5. In that task search-->Terraform installer>add
	- Display Name: Install Terraform
	- version: 1.6.6
6. Repeat step4 which is called adding tasks. search for Terraform CLI>add
	- Display Name: Initialize Terraform
	- command : init
	- configuration directory: $(System.DefaultWorkingDirectory)
	- Command Options: -reconfigure
	- Backend Type: azurerm
	- AzureRM Backend Configuration
		- Backend Azure Service Connection: in the dropdown select your subscription and authorize if needed
		- Azure Tenant Id : your tenat id
		- Azure Subscription Id: your subscription id
		- Resource Group Name : your resource group name
		- Storage Account Name: your storage account name
		- Container Name: your container name
		- key : your storage account key
		
7. Repeat step4 which is called adding tasks. search for Terraform CLI>add
	- Display Name: Validating Terraform
	- command : validate
	- configuration directory: $(System.DefaultWorkingDirectory)
8. Repeat step4 which is called adding tasks. search for Terraform CLI>add
	- Display Name: Planning Terraform
	- command : plan
	- configuration directory: $(System.DefaultWorkingDirectory)
	- check Run Azure CLI Login
	- Command Options: -out=$(Build.SourcesDirectory)/tfplan
	- Providers
		- AzureRM Provider Service Connection: select your service connection
		- Azure Subscription Id: your subscription ID
9. Repeat step4 which is called adding tasks. publish Build Artifacts>add
		- Display Name: Building Artifact
		- Path to publish: $(Build.SourcesDirectory)
		- Artifact name: drop
		- Artifact publish location: Azure Pipelines

Click on Save&Queue and Run it
output: it should run successfully and produce an artifact named drop which contains all files like below
Screenshot:
		<img width="1617" height="873" alt="image" src="https://github.com/user-attachments/assets/2513d2cf-a40a-4a4a-a817-e1eb61c7a72e" />

Continuous Deployment:
------------
Navigate to pipelines>Releases>New Release pipeline

ARTIFACT SETTING:
-------------
- click on add an artifact which is shown in the UI
- project: select your project
- source(build pipeline): select your pipeline
- click ADD

STAGES:
------
- click on add stage which is shown in your current UI
- click on Empty job which located under the select a template
    - stage name: Release stages
    - click on 1 Job 0 task which is shown as below Screenshot
<img width="1630" height="884" alt="image" src="https://github.com/user-attachments/assets/64f370e1-aa01-4fd8-8193-a6086a614177" />

- Click on Agent Job
	- Display Name: Agent Job
	- Agent pool : Azure Pipelines
	- Agent Specification: ubuntu-22.04

- click on + symbol which is located right side of Agent job which is called adding tasks
- search for Terraform Installer>add
	- Display Name: Install Terraform
	- version : 1.6.6

- click on + symbol which is located right side of Agent job which is called adding tasks
- search for bash>add
	- Display name: bash script
	- type : inline
	- script : rm -rf .terraform
	- Advanced:
		- Working Directory: $(System.DefaultWorkingDirectory)/_Boot camp - 3-CI (1)/drop  #select your artifact you clicking the three dots

- click on + symbol which is located right side of Agent job which is called adding tasks
- search for Terraform CLI>add
	- Display Name : Terraform Init
	- command: init
	- configuration directory: $(System.DefaultWorkingDirectory)
	- Command Options: -reconfigure
	- Backend Type: azurerm
	- AzureRM Backend Configuration
		- Backend Azure Service Connection: in the dropdown select your subscription and authorize if needed
		- Azure Tenant Id : your tenat id
		- Azure Subscription Id: your subscription id
		- Resource Group Name : your resource group name
		- Storage Account Name: your storage account name
		- Container Name: your container name
		- key : your storage account key
	

- click on + symbol which is located right side of Agent job which is called adding tasks
- search for Terraform CLI>add
	- Display Name : Terraform Apply
	- command: apply
	- Configuration Directory: $(System.DefaultWorkingDirectory)/_Boot camp - 3-CI (1)/drop   #select yours by clicking on three dots
	- command options: -auto-approve tfplan
- providers
- AzureRM Provider Service Connection: select your service connection
- Azure Subscription Id : your subscription id

### click on save and click create release

## output : It should succed and create virtual machine in the portal go and check it
<img width="1616" height="882" alt="image" src="https://github.com/user-attachments/assets/791bae01-88d9-4e9b-9fef-dc5474efa9d7" />

