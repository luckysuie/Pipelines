### Steps
1. Create a resource group ex: banking-rg
2. Create a virtual network inside that resouce group ex: banking-vnet
3. Create three subnets(websubnet, dbsubnet, end-point-subnet, webapp-outbound-subnet) in the above virtual network
4. Create a windows virtual machine in websubnet named webvm and user clientuser
5. Create a windows virtual machine in dbsubnet named dbvm and user named dbuser
6. Create a ubuntu 24.04 virtual machine in websubnet named hostvm and user selfhostuser
7. Create an azure sql server in the above resouce group with both SQL and Microsoft authentication
    - server name: banking-sql-server8576
    - username: Admin
    - Password: Adminpassword123!
8. Create an Azure Sql database (bankingdb) with the above sql server and do the networking section as below
    - Click on add private end point and crete it with new private end point
      - Name:db-end-point
      - Target sub resource: Sqlserver
      - Virtual network: banking-vnet
      - Subnet: end-point-subnet
      - Integrate with private DNS zone
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
# 1. Ensure TLS 1.2 is used for the download
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# 2. Download the latest SSMS installer
Write-Host "Downloading SSMS Installer (this may take a few minutes)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $Url -OutFile $Path
# 3. Run the installer silently
# /Install = Start installation
# /Passive = Show progress bar but no user interaction
# /NoRestart = Don't force a reboot immediately
Write-Host "Installing SSMS..." -ForegroundColor Cyan
Start-Process -FilePath $Path -ArgumentList "/Install", "/Passive", "/NoRestart" -Wait
# 4. Cleanup
Remove-Item -Path $Path
Write-Host "SSMS Installation Complete! Please restart your VM to finalize." -ForegroundColor Green
```


