# Pipeline 12 : Deploying a Java spring boot application to AKS using Jenkins via Maven, SonarQube, Docker, Trivy, ACR

Steps: 
-----------
Repo : https://github.com/spring-projects/spring-petclinic
1. Fork the above repo to your GitHub account
2. Clone the forked repo to local folder and open it using Visual studio code
3. create an with named demo11 and ubuntu VM in it with at least 2 CPU and 4GB Ram with all ports open
4. Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg: lucky
5. Navigate to lucky > top right secret > create a secret Now note down
```bash
Application (client) ID: XXXXXXXXXXXXXXXXXXXXXXXXXX
Directory (tenant) ID :XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
value : XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```
6. Assign owner Role to lucky
7. Login to VM via ssh and do below
```bash
sudo apt update
vi installations.sh # put the below file content in it
sh installations.sh # Run the file it will install the necessary things
```
below is the file for installations.sh it installs below
https://github.com/luckysuie/Pipelines/blob/main/Pipeline-12/installations.sh
- Git
- Java
- Jenkins
- Docker
- Trivy
- Azure CLI
- kubectl

8. Login to your Azure account using below
```bash
	az login --use-device-code
```
10. Configure webhook for the forked repo

- Navigate to you repository
- Click on Settings
- On the left pane select webhooks
- Add webhook
- Payload URL: http://yourvmip:8080/github-webhook/
- Ssl certificate: Disable
- Check push the event
- Click on add webhook

10. Jenkins and Plugins setup
- Browse the publicip of VM with port 8080
- Copy this /var/lib/jenkins/secrets/initialAdminPassword
- Navigate to VM and type below sudo cat /var/lib/jenkins/secrets/initialAdminPassword
- you will get the password copy and paste it in the browser then select insalled plugins
- create username and password like admin for both user and password
- Now click on start using Jenkins then you will see your Jenkins UI
- Manage jenkins>Plugins>Available Plugins search for pipeline stage view and install
- Manage jenkins>Plugins>Available Plugins search for Maven and install
- Manage jenkins>plugins>available Plugins search SonarQube scanner and install

11. Sonarcloud account
- Navigate to your sonarcloud Account
- create a organization if you don't have
- create a project named Jenkins project
- Generate a token


12. Credentials setup
- Manage Jenkins>credentials>global> Add credentials
- add your sonarcloud credentials

- Manage Jenkins>credentials>global> Add credentials
- add your Azure cloud account details

please refer below for detailed info
https://github.com/luckysuie/Pipelines/tree/main/Pipeline-11

13. create an Azure container Registry
```bash
az acr create --resource-group demo11 --name luckyregistry --sku Basic
```
14. create an aks cluster
```bash
az aks create   --resource-group demo11   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys
```
15. configure your local kubectl client to connect and manage a specific Azure Kubernetes Service (AKS) cluster
```bash
az aks get-credentials --resource-group demo11   --name lucky-aks-cluster11
```
16. create an ACR secret by using below. The purpose of this is pulls the image from acr to deployment
```bash
kubectl create secret docker-registry acr-secret \
  --docker-server=luckyregistry.azurecr.io \
  --docker-username=luckyregistry \
  --docker-password=youregistrypassword \
  --docker-email=example@gmail.com 
```

17. Pipeline Trigger setup
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

18. Navigate to visual studio code which you opened already
create a Jenkins file if not there and start writing the pipeline for the Below states

- Git Checkout
- Maven validate
- maven compile
- Maven test
- maven package
- sonarcloud analysis
- publishing the sonar report
- Building the Docker image
- Scanning the image using Trivy
- Login to ACR and pushing the image to ACR
- Deploy to Kubernetes

## Testings
Browse the loadbalancer ip of your cluster and you will see the page

<img width="1372" height="789" alt="Screenshot 2025-07-15 185948" src="https://github.com/user-attachments/assets/dcd021d8-7860-45bb-acee-59a3085be7ad" />
<img width="1723" height="904" alt="image" src="https://github.com/user-attachments/assets/66285569-595f-4c79-827c-0e5b647d68ad" />

