## Secure Digital Banking two tier Application Deployment on Azure Using Private Networking and Azure DevOps CI/CD

### Technology Stack

| Technology | Usage in the Project |
|------------|----------------------|
| Microsoft Azure | Cloud platform used to host the complete banking application and infrastructure. |
| Azure App Service | Hosts the Java Spring Boot banking application. |
| Azure Virtual Network (VNet) | Provides secure private networking between Azure resources. |
| Azure Private Endpoint | Enables private access to Azure App Service, Azure SQL Database, and Azure Key Vault. |
| Azure Private DNS Zone | Resolves Azure service names to their private endpoint IP addresses. |
| Azure SQL Database | Stores banking application data such as customers, accounts, payments, and transactions. |
| Azure Key Vault | Securely stores database credentials and application secrets. |
| Microsoft Entra ID & RBAC | Provides identity management and role-based access control for Azure resources. |
| Java 21 | Backend programming language used to develop the banking application. |
| Spring Boot | Framework used to build REST APIs and integrate Azure services. |
| Maven | Builds, packages, and manages Java project dependencies. |
| Node.js & npm | Builds the frontend application before deployment. |
| Git & GitHub | Version control and source code repository management. |
| Azure DevOps | Implements CI/CD pipelines, service connections, and deployment automation. |
| Self-Hosted Azure DevOps Agent | Executes build and deployment pipelines securely from within the Azure Virtual Network. |

### Architecture Diagram

### Defnitions
- Network Security Group (NSG): An Azure Network Security Group (NSG) filters network traffic by allowing or denying inbound and outbound connections to Azure resources using security rules.
- NSG Inbound Rule: An NSG inbound rule controls incoming network traffic to an Azure resource by allowing or denying connections based on source, destination, port, and protocol.
- NSG Outbound Rule: An NSG outbound rule controls outgoing network traffic from an Azure resource by allowing or denying connections based on destination, port, and protocol.
- A Private Endpoint is a private IP address created inside your VNet that gives secure access to an Azure PaaS service (App Service, SQL Database, Key Vault, Storage, etc.) without exposing that service to the public internet.
- A Private DNS Zone stores the mapping between an Azure service's name and its Private Endpoint IP address, so applications can find the service over the private network.
- Private End point: Private Endpoint gives the service a private IP
- Private DNS Zone: Private DNS Zone remembers which service name belongs to that private IP

### Steps
0. Fork this repo to your Github Repo: https://github.com/luckysuie/banking 
1. Create a resource group ex: banking-rg
2. Create a virtual network inside that resouce group ex: banking-vnet
3. Create three subnets(websubnet, dbsubnet, end-point-subnet, webapp-outbound-subnet) in the above virtual network
4. Create a windows virtual machine in websubnet named webvm and username clientuser and password clientuser@1234
5. Create a windows virtual machine in dbsubnet named dbvm and username named dbuser and passoword dbuser@1234567
6. Create a ubuntu 24.04 virtual machine in websubnet named hostvm and username selfhostuser and password selfhostuser@1234
7. Create an sql server in the above resouce group with both SQL and Microsoft authentication
    - server name: banking-sql-server8576  #you can give anyname
    - username: bankingadmin
    - Password: LuckyPassword@1234
    - Firewall rules: Allow Azure services and resources to access this server: no
    - Reveiw and create
8. Create an Azure Sql database (bankingdb) with the above sql server and do the networking section as below
    - Add current client IP address: No
    - Click on add private end point and crete it with new private end point
      - Name:db-end-point
      - Target sub resource: Sqlserver
      - Virtual network: banking-vnet
      - Subnet: end-point-subnet
      - Integrate with private DNS zone: Yes
      - Finally Review and Create
9. Create an Azure app service plan atleast with B3 size or premium in the above resource group
10. Create an azure webapp with below configuration
    - Runtime stack : java 21
    - Name: banking-webapp   ## you can give anyother name as well
    - Networking: 
        - public access: off
        - Enable Virtual Integration
            - Virtal Network: banking-vnet
                - Inbound Access section of Enable private endpoints: on
                - Private end point Name: inbound-pe
                - Inbound subnet: end-point-subnet
                - DNS: Azure private DNS zone
            - Enable Vnet integration: on
                - Subnet : webapp-outbound-subnet
    - Finally review and Create
11. Installation of chrome and SSMS. Connect to the both windows VMS and open powershell as Admisnistrator and run the below Scripts
- Chrome installation script
```bash
# Define the path for the installer
$Path = "$env:TEMP\ChromeInstaller.exe"
# Download the latest Chrome installer
Write-Host "Downloading Chrome..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $Path
# Run the installer silently
Write-Host "Installing Chrome..." -ForegroundColor Cyan
Start-Process -FilePath $Path -ArgumentList "/silent", "/install" -Wait
# Clean up the installer file
Remove-Item -Path $Path
Write-Host "Installation Complete!" -ForegroundColor Green
```

- SSMS 22 Installation script
```bash
#$path="$env:TEMP\SSMS-Setup.exe"
Invoke-WebRequest "https://aka.ms/ssmsfullsetup" -OutFile $path
Start-Process $path -ArgumentList "/install","/passive","/norestart" -Wait
Remove-Item $path -Force
Write-Host "SSMS installed successfully." -ForegroundColor Green
```

- Install Azure CLI only on webvm 
    - open google chrome of what you have installed and open the below url
        ```bash https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=msi ```
    - scroll down and select MS Installer(MSI) and scroll down a bit more and click on latest MSI of the Azure CLI(64-bit). It will be downloaded. open it and run it
    - Open command prompt and check version with command az version
    - Login to your Azure account with command az login --use-device-code

- Install Git bash only on webvm using below
    - open google chrome of what you have installed and open the below url ```bash https://git-scm.com/install/windows ```
    - Standalone Installer: Git for Windows/x64 Setup. click this it will be downloaded
    - open it and run it

### Restricting Azure Web App and Azure SQL Database Using Private Endpoint and NSG
1. Objective
- The goal is to configure the environment so that:
    - The Azure Web App is accessible only from the VM in websubnet.
    - The Azure SQL Database is accessible only from the VM in dbsubnet.
    - The Web App can also connect to Azure SQL through VNet Integration.
    - Public access to both services remains disabled.
- Part 1: Restrict Azure Web App Access
    - Verify the Web App Private Endpoint
        - Open Azure Portal → Private Endpoints → Select the Web App private endpoint (inbound-pe).
        - Open the associated Network Interface (NIC) and note the assigned Private IP Address.
        - Use this Private IP (e.g., 10.0.2.5) as the destination in the NSG rules.
    - Enable Network Policies on the Private Endpoint Subnet
        - Open banking-vnet → Subnets → Select end-point-subnet.
        - Under Network policy for private endpoints, enable Network Security Groups.
        - Save the configuration to allow the NSG to control traffic to private endpoints.
    - Create and associate an NSG with the Endpoint Subnet
        - Open NSG in portal create with name endpoint-nsg. Asssociate it with end-point-subnet 
        - Verify that the NSG is linked to banking-vnet/end-point-subnet.
        - The same NSG can be used to manage traffic for both the Web App and Azure SQL private endpoints.
    - Allow Web Subnet Access to the Web App
        - Create an inbound rule with the following settings:
            | Setting | Value |
            | :--- | :--- |
            | Source | IP Addresses |
            | Source IP | websubnet CIDR |
            | Destination | IP Addresses |
            | Destination IP | Web App private endpoint IP |
            | Service | HTTPS |
            | Protocol | TCP |
            | Destination port | 443 |
            | Action | Allow |
            | Priority | 100 |
            | Name | Allow-WebSubnet-To-WebApp |
    - Deny Other VNet Subnets from Accessing the Web App
        - Create another inbound rule with Below settings
            | Setting | Value |
            | :--- | :--- |
            | Source | Service Tag |
            | Source service Tag | Virtual network |
            | Destination | IP Addresses |
            | Destination IP | Web App private endpoint IP with /32 |
            | Service | HTTPS |
            | Protocol | TCP |
            | Destination port | 443 |
            | Action | Deny |
            | Priority | 200 |
            | Name | Deny-Other-Subnets-To-WebApp |
        - This rule blocks the DB VM and other VNet resources from accessing the Web App.
    - Step 6: Test the Web App Access
        - open the webapp URL in the webvm it should work
        - open the webapp URL in the database vm it shouldnot work

- Part 2: Restrict Azure SQL Database Access
    - Verify the SQL Private Endpoint
        - Open Azure Portal → Private Endpoints → Select db-end-point.
        - Open the associated Network Interface (NIC) and note the assigned Private IP Address.
        - Use this Private IP (e.g., 10.0.2.4) as the destination in the NSG rules for the Azure SQL private endpoint.
    - Allow DB Subnet Access to Azure SQL
        - Create an inbound rule with below settings

            | Setting | Value |
            | :--- | :--- |
            | Source | IP Addresses |
            | Source IP | dbsubnet CIDR |
            | Destination | IP Addresses |
            | Destination IP | SQL private endpoint IP |
            | Service | MS SQL |
            | Protocol | TCP |
            | Destination port | 1433 |
            | Action | Allow |
            | Priority | 110 |
            | Name | Allow-DBSubnet-To-AzureSQL |
    - Allow the Web App to Connect to Azure SQL
        - Because the Web App uses VNet Integration through webapp-outbound-subnet, add another inbound rule

        | Setting | Value |
        | :--- | :--- |
        | Source | IP Addresses |
        | Source IP | webapp-outbound-subnet CIDR |
        | Destination | IP Addresses |
        | Destination IP | SQL private endpoint IP address |
        | Service | MS SQL |
        | Protocol | TCP |
        | Destination port | 1433 |
        | Action | Allow |
        | Priority | 120 |
        | Name | Allow-WebApp-To-AzureSQL |

        - This allows the Java Web App to connect to the Azure SQL Database privately. 
    - Deny Other Subnets from Accessing Azure SQL
        - Create another inbound rule:
            | Setting | Value |
            | :--- | :--- |
            | Source | Service Tag |
            | Source Service Tag  | Virtual network |
            | Destination | IP Addresses |
            | Destination IP | SQL private endpoint |
            | Service | MS SQL |
            | Protocol | TCP |
            | Destination port | 1433 |
            | Action | Deny |
            | Priority | 210 |
            | Name | Deny-Other-Subnets-To-AzureSQL |
    - Test Azure SQL Connectivity
        - Open ssms which you installed in the dbvm and try to connect it using servername and sql authentication it should connect
        - Open ssms which you installed in the webvm and try to connect it using servername and sql authentication it should not connect
    - Final NSG Rule Summary
        - Lower priority numbers are processed first.
            | Priority | Rule |
            | :--- | :--- |
            | 100 | Allow websubnet to Web App private endpoint on port 443 |
            | 110 | Allow dbsubnet to SQL private endpoint on port 1433 |
            | 120 | Allow webapp-outbound-subnet to SQL private endpoint on port 1433 |
            | 200 | Deny other VNet subnets from Web App private endpoint |
            | 210 | Deny other VNet subnets from SQL private endpoint |
- Final Expected Result
    - Local Computer: Web App and Azure SQL access are blocked.
    - Client VM (websubnet): Web App is allowed, but Azure SQL is blocked.
    - DB VM (dbsubnet): Azure SQL is allowed, but the Web App is blocked.
    - Azure Web App: Azure SQL access is allowed through webapp-outbound-subnet.



2. Create an Azure Key Vault

    - Create an Azure Key Vault using the name banking-kv-123479 or another globally unique name. Make sure to note the Key Vault name, as it will be required in the upcoming steps.

    - During the Key Vault creation process, configure the networking settings as follows:
        - Disable public network access by unchecking Enable public access.
        - Click Add a private endpoint.
        - Enter the private endpoint name as vault-end-point or another suitable name.
        - Select Vault as the target sub-resource.
        - Select endpoint-subnet as the subnet.
        - Select Yes for integration with a private DNS zone.

    - Keyvault name check
        - Navigate to your forked repo and go to banking/digital-banking-platform/src/main/resources/application-azure.yml
        - On the 20th line ensure you have same keyvault name if not change it and commit
    - After the Key Vault and private endpoint are created, connect to the webvm.
        - From the webvm:
            - Open the Git bash.
            - Run the required Azure CLI commands.
- Question: Why do we need to run commands from the webvm? Can we run the same commands from Azure Cloud Shell on our local computer?

- Answer: No, the commands cannot be successfully executed from the local computer when public network access to the Key Vault is disabled.

- The Key Vault is configured with a private endpoint, which means it can only be accessed through its private IP address from within the connected virtual network. The webvm is deployed inside the banking virtual network and can communicate with the Key Vault through the private endpoint and private DNS zone.

- Azure Cloud Shell opened from the local computer runs outside the banking virtual network. Therefore, it does not have a private network path to the Key Vault and the commands may fail with an access or network authorization error.


- Assign Key Vault Administrator role to the signed-in user for the Key Vault
```bash
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
KV_ID=$(az keyvault show --name banking-kv-123479 --resource-group banking-rg --query id -o tsv)
az role assignment create --assignee $USER_OBJECT_ID --role "Key Vault Administrator" --scope $KV_ID
```

- Store the database connection string, username, and password as secrets in Azure Key Vault
```bash
az keyvault secret set --vault-name banking-kv-123479 --name "sql-jdbc-url" --value "jdbc:sqlserver://banking-sql-server8576.database.windows.net:1433;database=bankingdb;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
az keyvault secret set --vault-name banking-kv-123479 --name "sql-admin-username" --value "bankingadmin"
az keyvault secret set --vault-name banking-kv-123479 --name "sql-admin-password" --value "LuckyPassword@1234"
```

- Configure Application Settings and Enable Managed Identity
```bash
az webapp config appsettings set --name banking-webapp --resource-group banking-rg --settings AZURE_KEYVAULT_ENDPOINT=https://banking-kv-123479.vault.azure.net/ SPRING_PROFILES_ACTIVE=azure
az webapp config appsettings set --name banking-webapp --resource-group banking-rg --settings APP_DATA_INITIALIZE=true
az webapp identity assign --name banking-webapp --resource-group banking-rg
```

- Assign the Key Vault Secrets User role to the web app's managed identity for accessing secrets in Key Vault
```bash
APP_PRINCIPAL_ID=$(az webapp show --name banking-webapp --resource-group banking-rg --query identity.principalId -o tsv)
KV_ID=$(az keyvault show --name banking-kv-123479 --resource-group banking-rg --query id -o tsv)
az role assignment create --assignee-object-id $APP_PRINCIPAL_ID --assignee-principal-type ServicePrincipal --role "Key Vault Secrets User" --scope $KV_ID
```
- Create a Service Principal for Azure DevOps Deployment
```bash
az ad sp create-for-rbac --name banking-devops-sp --role Contributor --scopes /subscriptions/yoursubscriptioid
```
- Example output

```bash
{
  "appId": "yourappidhere",
  "displayName": "banking-devops-sp",
  "password": "yourpasswordhere",
  "tenant": "yourtenatindhere"
}
```
- connect to your ubuntu VM which you created at starting and install the below things
    - Install java 21
```bash
    sudo apt update
    sudo apt install openjdk-21-jdk -y
    java -version
```
 - Install Git
```bash
sudo apt update
sudo apt install git -y
git --version
```
 - Install Azure cli
```bash
sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```
 - Login into your account
```bash
az login --use-device-code
```
 - Install maven
```bash
sudo apt update
sudo apt install maven -y
mvn -v
```
 - Install Node js 20 (run one after another this one)
```bash
sudo apt update
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
source ~/.bashrc
nvm install 20
node -v
npm -v
```

- service connection setup
    - Navigate to your Azure devops portal
    - Create a new project on the top right named webapp project or any other
    - Naviagte to project settings>servce connections 
    - New service connection: Azure resource manager
        - Identity type: app registration or managed identity(manual)
        - Credential: secret
        - Environment : Azure cloud
        - Scope level: subscription
        - Subscription ID: give your subsctiption id
        - Subscription name: give your subscrition name
        - Application (client) ID: Give the appid which you generated earlier
        - Directory (tenant) ID: give the tenant id which you generated earlier
        - Client secret: give the password which you generated earlier
        - Service connection name: banking-service-connec  ## you can use any other but note it for pipeliens
        - Security: Grant access permission to all pipelines(Check it)
    - Finally verify and save.

### Configure Azure DevOps Self-Hosted Agent (Ubuntu VM)
1. Create an Agent Pool at the Organization Level
    - Sign in to Azure DevOps. 
    - Navigate to Organization Settings. 
    - Select Agent Pools. 
        - Click Add Pool. 
        - Configure the pool: 
        - Pool Type: Self-hosted 
        - Pool Name: Banking-Agent-Pool 
        - Enable Auto-provision this agent pool in all projects 
    - Click Create. 

2. Download the Linux Agent
    - Open the newly created Banking-Agent-Pool. 
    - Click New Agent. 
    - Select: 
    - Operating System: Linux 
    - Architecture: x64 
    - Copy the wget download command displayed in Azure DevOps. 

3. Connect to the Ubuntu VM
    - Connect to the Ubuntu VM using SSH (Terminal or PuTTY).
    - Update the package repository:
```bash
sudo apt update
```
 - Create a folder for the Azure DevOps agent:
```bash
mkdir ~/agent
cd ~/agent
```
4. Download and Extract the Agent
    - Paste the wget command copied from Azure DevOps. Example: wget https://download.agent.dev.azure.com/agent/4.xxx.x/vsts-agent-linux-x64-4.xxx.x.tar.gz
    - Extract the downloaded package:
```bash
tar -xvzf vsts-agent-linux-x64-4.xxx.x.tar.gz
```
 - Verify the extracted files:
```bash
ls
```

5. Configure the Azure DevOps Agent
    - Run the configuration script:
```bash
./config.sh
```
 - Provide the following details when prompted:
    | Prompt | Value / Configuration |
    | :--- | :--- |
    | **Accept Team Explorer Everywhere License** | Press <kbd>Enter</kbd> *(Default: N)* |
    | **Server URL** | `https://dev.azure.com/<your-organization-name>` |
    | **Authentication Type** | Press <kbd>Enter</kbd> *(PAT)* |
    | **Personal Access Token** | *Paste your Azure DevOps PAT* *(Full Access recommended)* |
    | **Agent Pool** | `Banking-Agent-Pool` |
    | **Agent Name** | `banking-linux-agent` *(or any preferred name)* |
    | **Work Folder** | Press <kbd>Enter</kbd> *(Default: `_work`)* |
- After the configuration completes successfully, verify the files using ls command


6. Verify the Agent
 - Start the agent manually:
```bash
./run.sh
```
 - Navigate to: Azure DevOps → Organization Settings → Agent Pools → Banking-Agent-Pool
 - Verify that the agent status is Online.

- Run the Agent as a Service (Recommended)
- Press Ctrl + C to stop the manually running agent.
- Install the agent as a Linux service:
```bash
sudo ./svc.sh install
```
- Start the service:
```bash
sudo ./svc.sh start
```
- Verify the service status:
```bash
sudo ./svc.sh status
```
- A successful status indicates that the Azure DevOps agent is running as a background service and will automatically start whenever the Ubuntu VM is restarted.

- Final Verification
    - Navigate to:Azure DevOps → Organization Settings → Agent Pools → Banking-Agent-Pool
    - Confirm that:
        - Agent Name: banking-linux-agent 
        - Status: Online 
- Your Ubuntu VM is now ready to execute Azure DevOps build and deployment pipelines.


### Azure DevOps CI/CD Pipeline Steps
- Now navigate to your webapp project on the left side click on pipelines the selct github. Then slect your forked repo then click on starter pipeline. now start writing the pipleine with below hints
    - Checkout Code: Checks out repository code and performs a clean workspace setup.
    - Use Node.js 20: Installs Node.js version 20.x environment.
    - Clean backend: Runs mvn clean on the backend project.
    - Build frontend: Installs npm packages, builds the frontend, and verifies index.html.
    - Copy frontend: Copies compiled frontend assets into the backend static resources folder.
    - Build JAR: Packages the combined Spring Boot application into a executable JAR.
    - Verify JAR: Verifies the embedded assets inside the JAR file and stages the artifact.
    - Deploy application: Deploys the packaged .jar file to the Linux Azure Web App.
- pipeline should be succesfull

- Navigate to the dbvm and open ssms 22 whch we already installed and connect to the server
    - servername: banking-sql-server8576.database.windows.net 
    - authentication: sql authentication
    - userame: bankingadmin
    - password: LuckyPassword@1234

- After connecting succesfully. click on the new query and execute one by one below
```bash
SELECT name FROM sys.tables ORDER BY name;
SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM beneficiaries;
SELECT * FROM payments;
SELECT * FROM transactions;
SELECT * FROM notifications;
SELECT * FROM audit_events;
SELECT * FROM flyway_schema_history;
```


### Outputs and validations
- Pipeline succesfull
- Able to open webapp URL in the webvm
- Able to query the sql in the dbvm
- Not able to open the webapp URL from dbvm
- Not able to open the webapp URL from your local computer
- Not able to query the sql in the webvm
- Default Monitoring available in the webapp








