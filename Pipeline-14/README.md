# Pipeline-14: write a Terraform script for custom policy creation in Azure and deploy it Via Jenkins and Analyze the written script using SonarQube in the Jenkins pipeline itself

Steps:
------------
1. create a resource group with named demo11 and ubuntu VM in it with at least 2 CPU and 4GB Ram with all ports open
2. Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg: lucky
3. Navigate to lucky > top right secret > create a secret Now note down
```bash
Application (client) ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Object ID :xxxxxxxxxxxxxxxxxxxxxxxx
Directory (tenant) ID :xxxxxxxxxxxxxxxxxxxx
value : xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Secret ID: Xxxxxxxxxxxxxxxxxxxxxxxxx
subscription ID: Xxxxxxxxxxxxxxxxxxxxxxxx
```
4. Assigning Role to lucky
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
Assign Access to User
  - In the Members tab:
  - Scope: Leave as default (User, group, or service principal)
  - Click "+ Select members"
  - Type lucky in the search bar
  - Select the matching user account
  - Click "Select" • Click "Next"
- Set Conditions
  - In the Conditions (preview) tab:
  - Choose the recommended condition shown (typically for least privilege or conditional access context)
  - Review what the condition does
  - Click "Next"
- Review and Assign
  - Review all your selections
  - Click "Review + assign"

5. Login to VM using ssh
6. Install Git, java, Jenkins, Terraform, Azure CLI, Docker, SonarQube as a container
7. please follow below process for the installation of above
```bash
sudo apt update
vi installations.sh # put the below file content given below in it and save it
sh installations.sh # Run the file it will install the necessary things
```
### Installations file
```bash   - 
#Installing Required things
#Git Installation
sudo apt update
sudo apt install git -y

#Java Installation
sudo apt update
sudo apt install openjdk-21-jdk -y

#Jenkins Installation
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

#Docker Installation
sudo apt update
wget -O docker.sh https://get.docker.com/
sudo sh docker.sh

#Terraform Installation
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y

#Azure CLI Installation
sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# SonarQube as a container
sudo docker pull sonarqube 
sudo docker run -d -p 9000:9000 sonarqube

#Installations checking
git --version
java --version
jenkins --version
terraform --version
docker --version
az --version
```

Testing:
-----
- Browse public ip with port 8080 you should see your Jenkins login page---> http://yourvmip:8080/
- Browse public ip with port 8080 you should see your sonarqube login page---> http://yourvmip:9000/
- Login to your Azure account ``` az login --use-device-code ``` you should succesfully login to your account. 

Repository and webhook setup
-------------
- create a repository in the GitHub named custompolicy
- Configure webhook for that repository
    - Navigate to you repository
    - Click on Settings
    - On the left pane select webhooks
- Add webhook
  -  Payload URL: http://yourvmip:8080/github-webhook/
  -  Ssl certificate: Disable
  -  Check push the event
  -  Click on add webhook

<img width="1878" height="911" alt="image" src="https://github.com/user-attachments/assets/11a9540e-4d2f-482d-9828-672212455ebd" />

Jenkins and required plugins setup
-----------
- Copy this /var/lib/jenkins/secrets/initialAdminPassword which shown in your Jenkins UI
- Navigate to VM and type below sudo cat /var/lib/jenkins/secrets/initialAdminPassword
- you will get the password copy and paste it in the browser then select insalled plugins
- create username and password like admin for both user and password
- Now click on start using Jenkins then you will see your Jenkins UI
- Manage jenkins>Plugins>Available Plugins search for pipeline stage view and install


Pipeline Trigger setup
------
- Navigate to Jenkins UI
- New item
- Select pipeline
- Click ok
- Navigate to your item click on configure
- Navigate to pipeline section
  - Select pipeline script definition as pipeline script as scm
  - Give your GitHub reo url
  - Enter the correct branch #means main or master check your githubrepo and add carefully
  - Click on apply
- Triggers Section
  - GitHub hook trigger for GITScm polling – > check this
-click apply

sonarqube setup
--------------
Navigate to sonarqube Login page which you browsed earler
- username : admin
- password: admin 
- click on Login

set up new password:
---
- old password : admin
- new password : Lakshmi@123456789
- confirm new password : Lakshmi@123456789

- now you will see your SonarQube official page
  - click on create a project locally then provide ** project name** and **key**


Credentials setup in Jenkins
------------
Azure cloud credentials configuration
------------
Manage Jenkins>credentials>system>+Add credentials
- New credentials: kind : username and password as shown below
    - username: your client ID
    - password: value
ID :azure-sp
<img width="1895" height="891" alt="Screenshot 2025-07-27 101700" src="https://github.com/user-attachments/assets/af399c33-ff00-4433-9e8e-29dbf742aa3d" />

- New credentials: kind : secret text as shown below
  - secret : Directory(tenant ID)
  - ID: azure-tenant
<img width="1888" height="654" alt="Screenshot 2025-07-27 102025" src="https://github.com/user-attachments/assets/7dcb9f3b-0f79-4771-9487-77a761aa4e47" />

sonarqube credentials configuration
-----------
-  Navigate to Sonqube>my account>security>Generate a token and note it done
- Manage Jenkins>credentials>system>+Add credentials
  - New credentials: kind : secret text as shown below
  - Secret: your sonarqube token
  - ID : sonar-token
<img width="1883" height="661" alt="Screenshot 2025-07-27 102344" src="https://github.com/user-attachments/assets/ce6af2d1-a367-406f-849a-b1e6e0d95adb" />

## Final credentials setUp

<img width="1876" height="518" alt="Screenshot 2025-07-27 102432" src="https://github.com/user-attachments/assets/7a7365b5-57ca-47f4-8833-4366d5b6ad41" />

SonarQube Intergration:
----------
- Manage jenkins>Plugins>Available Plugins search for sonarqube scanner and install
- Manage jenkins>system>SonarQube servers
  - SonarQube installations
    - Name: sonarserver
    - server URL : http://yourvmip:9000/
    - Server authentication token: sonar-token
    - click add 
    - click apply 
please refer below image

<img width="1715" height="928" alt="Screenshot 2025-07-27 105903" src="https://github.com/user-attachments/assets/9530e23c-c29e-49b2-9eb9-85f6e25ff564" />

- Manage jenkins>Tools>SonarQube Scanner installations
-  SonarQube Scanner
  - Name: sonarqube
  -  click apply
please refer below Diagram

<img width="1771" height="923" alt="Screenshot 2025-07-27 110135" src="https://github.com/user-attachments/assets/1f4dab95-3cea-4299-8fc2-8e3325b3925f" />



