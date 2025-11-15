## Pipeline-18 : Automated Azure VM Lifecycle Management Using Jenkins Pipeline
<p>Build a Jenkins pipeline that manages an Azure VM automatically. The pipeline checks the VM state, starts it if stopped, and prompts for approval to stop or restart it if already running.</p>

1. Create the Resource Group
  - Create a resource group in any Azure region, for example Canada Central.
```bash
az group create --name lucky --location canadacentral
```
2. Create Two Virtual Machines
  - Create two VMs inside the same resource group:
    - Testuser
    - jenkins-vm
- Do not change the VM names.
3. Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg: lucky
4. Navigate to lucky > top right secret > create a secret Now note down
```bash
Application (client) ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Object ID :xxxxxxxxxxxxxxxxxxxxxxxx
Directory (tenant) ID :xxxxxxxxxxxxxxxxxxxx
value : xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Secret ID: Xxxxxxxxxxxxxxxxxxxxxxxxx
subscription ID: Xxxxxxxxxxxxxxxxxxxxxxxx
```
These values are required for authentication from Jenkins.

5. Assign Contributor Role
Assign the Contributor role to the service principal:
```bash
az role assignment create \
  --assignee <ApplicationID> \
  --role Contributor \
  --scope /subscriptions/<SubscriptionID>
```
6. Install Jenkins on jenkins-vm
  - Open all required ports for jenkins-vm.
  - SSH into the VM using port 22 and install Jenkins.

```bash
sudo aptupdate
sudo apt install openjdk-21-jdk -y
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
```


- Browse to:
  - http://<jenkins-vm-public-ip>:8080


- Follow setup steps, install suggested plugins, and create an admin user.

7. Install Pipeline Support Plugin
- Navigate to:
  - Manage Jenkins > Plugins > Available Plugins>Pipeline Stage View



8. Add Service Principal Credentials in Jenkins
- Navigate to:
  - Manage Jenkins > Credentials > Global
    - Add:
      - Azure service principal (username and password)
      - Tenant ID (secret text)

9. Create the Jenkins Pipeline
  - Navigate to Jenkins UI:
  - New Item
  - Choose Pipeline
  - Click OK
  - Go to Pipeline section
  - Add the pipeline script
10. Jenkins Pipeline Script
- Write stages for below
  - Login to Azure
  - Check VM power state
  - Start VM if stopped
  - Request approval if VM is running
  - Execute Stop, Restart, or No Action based on approval
11. Click on Build Now and observe the pipeline

- Asking Approval
<img width="1885" height="930" alt="Screenshot 2025-11-15 202046" src="https://github.com/user-attachments/assets/8b0e6a00-0493-4a96-853d-dafa45be1da8" />

- After Approval
<img width="1891" height="899" alt="Screenshot 2025-11-15 202153" src="https://github.com/user-attachments/assets/ddfa0c1c-bd90-47b3-86b9-30940c7ad4c3" />
