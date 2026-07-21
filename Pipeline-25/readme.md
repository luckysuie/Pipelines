### Steps
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








