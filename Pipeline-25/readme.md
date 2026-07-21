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
    - Login to your Azure account wth command az login --use-device-code

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





