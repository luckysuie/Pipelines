# Deploy a Node.js + MongoDB application to Azure App Service using Jenkins.

## Architecture Diagram
<img width="1888" height="768" alt="image" src="https://github.com/user-attachments/assets/aaa3797c-d8da-466d-abb9-3c0909edba83" />

Steps:
--------------
Repo: https://github.com/Azure-Samples/msdocs-nodejs-mongodb-azure-sample-app 

1. Fork the above repo to your GitHub account
2. Clone the forked repo to local folder and open it using Visual studio code
3. create an ubuntu VM with at least 2 CPU and 4GB Ram with all ports open
4. Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg:lucky
5. Navigate to lucky > top right secret > create a secret
    Now note down
- Application (client) ID: XXXXXXXXXXXXXXXXXXXXXXXXXX
- Directory (tenant) ID :XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
- value : XXXXXXXXXXXXXXXXXXXXXXXXXXXX

6. Assigning Role to lucky
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
7. Navigate to VM and install below

- Install Git
```bash
sudo apt update
sudo apt install git -y
```
- Install java
```bash
sudo apt update
sudo apt install openjdk-21-jdk -y
```
Install Jenkins
```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
```

Install Azure CLI
```bash
sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
Install Zip
```bash
sudo apt update
sudo apt install zip
```

7. Configure webhook for the forked repo
- Navigate to you repository
- Click on Settings
- On the left pane select webhooks
- Add webhook
- Payload URL: http://yourvmip:8080/github-webhook/ 
- Ssl certificate: Disable
- Check push the event
- Click on add webhook

8. Jenkins and Plugins setup
  - Browse the publicip of VM with port 8080
  - Copy this /var/lib/jenkins/secrets/initialAdminPassword
  - Navigate to VM and type below sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  - you will get the password copy and paste it in the browser then select insalled plugins
  - create username and password like admin for both user and password
  - Now click on start using Jenkins then you will see your Jenkins UI
  - Manage jenkins>Plugins>Available Plugins search for pipeline stage view and install
  - Manage jenkins>Plugins>Available Plugins search for NodeJs and install
  - Manage jenkins>Plugins>Available Plugins search for Copy Artifact and install

9. Adding Required credentials
  - Manage Jenkins>credentials>system>+Add credentials
  - New credentials: kind : username and password as shown below
<img width="1881" height="903" alt="Screenshot 2025-07-10 192828" src="https://github.com/user-attachments/assets/c5b42a73-795e-45d5-aa08-3c82625e3a2b" />

   - username: your client ID
   - password: value
   - ID :azure-sp

 - New credentials: kind : secret text as shown below
<img width="1908" height="847" alt="Screenshot 2025-07-10 192852" src="https://github.com/user-attachments/assets/4564494b-dbfb-4da2-bbf7-ecace49afb26" />

  - secret : Directory(tenant ID)
  - ID: azure-tenant

10. Pipeline Trigger setup
  - Navigate to Jenkins UI
    - New item
    - Select pipeline
    - Click ok
- Navigate to your item click on configure
  - Navigate to pipeline section
    - Select pipeline script definition as pipeline script as scm
    - Give your github reo url
    - Enter the correct branch
    - Click on apply
- Triggers Section
  - GitHub hook trigger for GITScm polling – > check this
  - click apply

11. Create Web app with database
- Option 1: By portal
  - Navigate to App servieces
  - select  webapp+database by clicking dropdown
     - subscription : your subscription
           - Resource group : your existing or any new
           - Region : Canada central
    - Web App Details
        - Name : lucky148715
        - Runtime Stack : NODE 20 LTS
    - Database
        - Engine : Cosmos DBI API for MongoDB
        - Account name : lucky148715-server
        - Database name : lucky148715-database
    - Azure Cache for Redis
        - Add Azure Cache for Redis? : No
    - Hosting
        - Hosting Plan : Basic - For hobby or research purposes
  - Review + Create
  - It will take 10-15 mins to deploy

- Option 2: using Terraform
  - create main.tf file which contains required things for the web app. FYI https://github.com/luckysuie/Pipelines/blob/main/Pipeline-11/main.tf
    - Apply the commands
  ```bash
  terraform init
  terraform validate
  terraform plan
  terraform --auto-approve
   ```
  - Note: It will take 15-20 mins to deploy

12. Navigate to Visual studio code which you previously opened
  - open New Terminal in it
  - navigate to your project folder
  - create a Jenkins file Named **Jenkinsfile** and start writing your pipeline for 

## Continuous Integration part
-----------------
- stage 1: checkout from git
- stage 2: Install dependencies
- stage 3: package app
- stage 4: publish artifact


## Continuous deployment part
----------------
- stage 5 : Download Artifact
- stage 6 : Login to Azure
- Stage 7 : Deploy to Azure web App


## Testing's: Browse the app Azure app service URL you will see your application

<img width="1890" height="954" alt="Screenshot 2025-07-10 185820" src="https://github.com/user-attachments/assets/6fe26205-cfee-42dd-bcc0-f0aed41ed651" />

