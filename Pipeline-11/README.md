# Deploy a Node.js + MongoDB application to Azure App Service using Jenkins.
Repo: https://github.com/Azure-Samples/msdocs-nodejs-mongodb-azure-sample-app 

Fork the above repo to your GitHub account
Clone the forked repo to local folder and open it using Visual studio code

create an ubuntu VM with at least 2 CPU and 4GB Ram with all ports open
Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg:lucky
Navigate to lucky > top right secret > create a secret
Now note down

Application (client) ID: XXXXXXXXXXXXXXXXXXXXXXXXXX
Directory (tenant) ID :XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
value : XXXXXXXXXXXXXXXXXXXXXXXXXXXX


Navigate to subscriptions> IAM > Add role assignments > Add privileged administrator roles>owner>select members>type lucky>next>conditions(check the recommended one) > review and assign

Install zip, Git, Java, Jenkins and Azure CLI

Install Git
sudo apt update
sudo apt install git -y

Install java
sudo apt update
sudo apt install openjdk-21-jdk -y

Install Jenkins

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

Install Azure CLI

sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

Install Zip

sudo apt update
sudo apt install zip


Configure webhook for the forked repo
Navigate to you repository
Click on Settings
On the left pane select webhooks
Add webhook
Payload URL: http://yourvmip:8080/github-webhook/ 
Ssl certificate: Disable
Check push the event
Click on add webhook


Browse the publicip of VM with port 8080
Copy this /var/lib/jenkins/secrets/initialAdminPassword
Navigate to VM and type below sudo cat /var/lib/jenkins/secrets/initialAdminPassword
you will get the password copy and paste it in the browser then select insalled plugins
create username and password like admin for both user and password
Now click on start using Jenkins then you will see your Jenkins UI
Manage jenkins>Plugins>Available Plugins search for pipeline stage view and install
Manage jenkins>Plugins>Available Plugins search for NodeJs and install
Manage jenkins>Plugins>Available Plugins search for Copy Artifact and install

Manage Jenkins>credentials>system>+Add credentials
New credentials: kind : username and password as shown below

username: your client ID
password: value
ID :azure-sp

New credentials: kind : secret text as shown below

secret : Directory(tenant ID)
ID: azure-tenant

Navigate to Jenkins UI
New item
Select pipeline
Click ok
Navigate to your item click on configure
Navigate to pipeline section
Select pipeline script definition as pipeline script as scm
Give your github reo url
Enter the correct branch
Click on apply
Triggers Section
GitHub hook trigger for GITScm polling – > check this
click apply

Navigate to your Azure portal
create a webapp+database using Azure app servicew with name luckywebapp in the above resource group
select the database while creating the webapp

Navigate to Visual studio code which you previously opened
open New Terminal in it
navigate to your project folder
create a Jenkins file Named Jenkinsfile and start writing your pipeline for 

Continuous Integration part
-----------------
stage 1: checkout from git
stage 2: Install dependencies
stage 3: package app
stage 4: publish artifact


Continuous deployment part
----------------
stage 5 : Download Artifact
stage 6 : Login to Azure
Stage 7 : Deploy to Azure web App


Testing's: Browse the app Azure app service URL you will see your application

