## Pipeline-16: Deploying a python application to AKS using docker, dockerhub,  sonarqube and Trivy with Jenkins

- Python repo: https://github.com/luckysuie/python-onepiece-app 
- Important Note: If you are doing with another repo or programming language repo make sure you have     Dockerfile and kubernetes yaml files without fail
1.	Fork the above repo to your GitHub account
2.	Clone the forked repo to local folder and open it using Visual studio code
3.	Create an ubuntu vm with at least 4cpu and 16gb of RAM with all ports open. as we are running sonarqube as well.but take a look on cost as well.
- Login into it and install below
1.	Git
```
sudo apt update
sudo apt install git -y
git --version
```bash

2. Python
```
sudo apt update
sudo apt install python3 python3-venv python3-pip python3-pytest -y
sudo apt install python-is-python3 -y
python --version
```bash

3.	Jenkins
```bash
sudo apt update
sudo apt install openjdk-21-jdk -y # Jenkins needs Java to run
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
```

4.Docker installation and configuration and adding Jenkins user to Docker group(Execute one after another below commands)
```bash
sudo apt update -y
wget -O docker.sh https://get.docker.com/
sudo sh docker.sh
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
sudo systemctl restart docker
sudo systemctl restart jenkins
newgrp docker
docker –version
```

5.	Sonarqube as container
```bash
docker pull sonarqube 
docker run -d -p 9000:9000 sonarqube
```

6.	Trivy
```bash
sudo apt update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
trivy --version
```

7.	Azure CLI
```bash
sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az –version
```

8.	Login to your acccount
```bash
az login –use-device-code
```

9.	Install Kubectl
```bash
sudo apt update
sudo snap install --classic kubectl
kubectl version --client
```

-Verifications: 
  - Browswe the publicip with 8080  you will see jenkins page
  - Browse the public ip with 9000 you will see soarqube login page
then login to jenkins and sonarqube

### PLUGINS:
- Manage jenkins>Plugins>Available Plugins search for pipeline stage view and install
- Manage jenkins>plugins>available Plugins search SonarQube scanner and install

### Pre-requisite for credentials
#### Sonarqube
  - Navigate to your sonarqube
  - create a project named Jenkins project
  - Make a note of the project token
  - Navigate to my account>security>generate a toekn
  - Save it in notepad or other

### Secure way of integrating Azure cloud to Jenkins without subscriptionID
- Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg: lucky
- Navigate to lucky > top right secret > create a secret Now note down
Assign Owner or contributor to lucky
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

- Make a note of below
```bash
Application (client) ID: XXXXXXXXXXXXXXXXXXXXXXXXXX
Directory (tenant) ID :XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Value(which is secret) : XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Dockerhub credentials
	- Navigate to dockerhub
	- Generate a PAT token
	- Make a note of username and PAT Token

## CREDENTIALS MANAGEMENT
- Navigate to Jenkins UI
- DockerHub Credentials setup
Manage Jenkins>credentials>system>+Add credentials
•	New credentials: kind : username and password 
o	username: yourdockerhubusername
o	password: dockerhubPATtoken 
o	ID : docker-hub-credentials #this ID important we will use this pipeline
Azure cloud Credentials setup
•	New credentials: kind : username and password 
•	username: your client ID
•	password: value 
•	ID :azure-sp #this ID important we will use this pipeline

•	New credentials: kind : secret text 
o	secret : Directory(tenant ID)
o	ID: azure-tenant #this ID important we will use this pipeline	
Sonarqube Credentials setup
•	New credentials: kind : secret text 
o	secret : yoursonarqubetoken
o	ID: sonarqube-token #this ID important we will use this pipeline	

 

Register your SonarQube server in Jenkins
Manage Jenkins → System → SonarQube servers → Add SonarQube
•	Name: sona	rqube-local
•	Server URL: http://172.172.149.37:9000    #in place of ip you should place yours
•	Server authentication token: choose the credential sonarqube-token
•	Click on apply

 Configure SonarQube Scanner in Jenkins (Tool Installation Setup)
Go to Manage Jenkins → Global Tool Configuration again.
•	Scroll down to SonarQube Scanner installations.
•	Name: sonar-scanner  #this is important we will use this pipeline
•	Version: SonarQube Scanner 7.3.0.5189
•	Install automatically: Enabled
•	Click apply





If you want you can configure webook otherwise write pipeline in local and paste in jenkins
But Recommended setup is webhook
Repository and webhook setup
•	Configure webhook for that repository
o	Navigate to you repository
o	Click on Settings
o	On the left pane select webhooks
•	Add webhook
o	Payload URL: http://yourvmip:8080/github-webhook/
o	Ssl certificate: Disable
o	Check push the event
o	Click on add webhook

Pipeline and its Trigger setup
•	Navigate to Jenkins UI
•	New item
•	Select pipeline
•	Click ok
•	Navigate to your item click on configure
•	Navigate to pipeline section
•	Select pipeline script definition as pipeline script as scm
•	Give your github reo url
•	Enter the correct branch 
•	Click on apply
•	Triggers Section
•	GitHub hook trigger for GITScm polling – > check this
•	click apply
18.	Navigate to visual studio code which you opened already create a Jenkins file for CI if not there and start writing the pipeline for the Below stages for Continous pipeline
CI PIPELINE

•	Git Checkout
•	Python Build
•	Python Test
•	sonarQube scan
•	publish sonarQube quality gate
•	Docker build and push
•	Trivy security scan and have that report as artifact
Recommended: Push stage by stage by stage so that it wll be error free and Good

Output:
 


CD PIPELINE:
Navigate to Azure portal
Create  a resource group named lucky or any other
Create an aks cluster using below in your Azure cloud shell using below command
az aks create   --resource-group lucky   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys

Navigate to Jenkins UI
Create another new item
Name it python-cd
Click ok
Now if you can use webhook or write in local and paste it jenkins
Stages:
1.	Log into Azure
2.	Deploy to Kubernetes

 

After succesfull deploy check whether he application is running or not by
Navigate to cloud shell where you created aks cluster then
	az aks get-credentials --resource-group lucky --name lucky-aks-cluster11 --overwrite-existing
	kubectl get all
then you will get like below
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
service/kubernetes        ClusterIP      10.0.0.1       <none>          443/TCP        17m
service/luckywebapp-svc   LoadBalancer   10.0.239.136   134.33.229.56   80:31887/TCP   9m59s
copy the external ip and paste in broswer

 
