# Pipeline 19: Java Spring Boot Deployment Pipeline with Jenkins, Argo CD & AKS
## ARCHITECTURE DIAGRAM
<img width="1823" height="745" alt="Screenshot 2025-11-30 200550" src="https://github.com/user-attachments/assets/0d65bad5-3114-4b23-9c98-104af05f05b4" />

### Phase 0: Pre-requisite:
------------
- You should have a java springboot application github repo(With or without database) which contains below mandatory files
1.	Dockerfile
2.	pom.xml
3.	K8s
	   - deployment.yaml
	   - service.yaml
	   - application.yaml
- My repo contains Azure SQL Database: https://github.com/luckysuie/Java-springboot 
### Phase 1: Basic Infra and Installations
1.	Create a resource group named lucky in canada central location and inside of it create a ubuntu VM with 4vCpus and 16GiB memoy with all ports open
2.	Login to VM using SSH and do the below
   - Install Git
   - Jenkins installation and verification
   - Docker Installation and rootless access setup then restart jenkins and docker after this(without fail)
   - Sonarqube as a Docker Container
   - Install AZ and Login to your Account
   - Install Kubectl
   - Install prometheus and grafana
- On your Ubuntu VM:
```bash
nano jenkins-docker-setup.sh
```
- Script Link: https://github.com/luckysuie/Pipelines/blob/main/Pipeline-19/jenkins-docker-setup.sh 
- Paste the entire script, save (Ctrl+O, Enter, Ctrl+X).
  - Make it executable:
```bash
chmod +x jenkins-docker-setup.sh
```
- Run it:
```bash
./jenkins-docker-setup.sh
```
2.a. Logout from the VM and re-login again and perform below 
```bash
nano devops-tools-setup.sh
```
- Script Link: https://github.com/luckysuie/Pipelines/blob/main/Pipeline-19/devops-tools-setup.sh 
- Paste the entire script, save (Ctrl+O, Enter, Ctrl+X).
  - Make it executable:
```bash
chmod +x devops-tools-setup.sh
```
- Run it:
```bash
./jenkins-docker-setup.sh
```
3. Login to Jenkins
  - Open your VM’s public IP in the browser with port 8080 : http://<Public-IP>:8080
  - On the VM terminal, get the Jenkins admin password:
  - sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  - Copy the displayed password and paste it into the Jenkins unlock page.
  - Choose Install suggested plugins.
  - Create your first admin user (e.g., username: admin, password: admin).
  - Click Start using Jenkins to access the Jenkins dashboard.
4.	Login to sonarqube
  - Browse public ip with port 9000 you should see your sonarqube login page---> http://yourvmip:9000/
  - Login and navigate to admin settings or account and generate a PAT token and make a note of that token
5.	Login to Azure cloud Account
```bash
az login --use-device-code
```
6.	Browse the public of your Vm with 9090 you should see prometheus page Prometheus -> http://<VM-IP>:9090
7.	Browse the public of your Vm with 3000 you should see Grafana Login page Grafana    -> http://<VM-IP>:3000
- Default login:
  - username: admin
  - password: admin
### Phase 3: Infra required for Pipelines
- Perform below either in the VM and for database use portal
1.	Create an Azure container Registry
```
az acr create --resource-group lucky --name luckyregistry --sku Basic
```
2.	Create an AKS cluster
```bash
az aks create   --resource-group lucky   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys
az aks get-credentials --resource-group lucky --name lucky-aks-cluster11
```
3. Enabling Authentication for ACR
	- Navigate to portal then resource group(lucky)
 	- search for your acr(luckyregistry) and open it
  	- In the left side search bar --> access keys
  		- Enable Admin user
    - Finally copy Login server, username and password
5. create an ACR secret by using below. The purpose of this is pulls the image from acr to deployment
```bash
kubectl create secret docker-registry acr-secret \
  --docker-server=luckyregistry.azurecr.io \
  --docker-username=luckyregistry \
  --docker-password=youregistrypassword \
  --docker-email=example@gmail.com 
```
  
6.	Create an Azure sql database
- Steps
1. Open SQL Database creation
    - Sign in to Azure Portal.
    - Search for SQL databases → click Create → SQL database.
- You are now on the Basics tab.
2. Apply free offer (if visible)
	- At the top of the Basics tab, if you see
	- “Want to try Azure SQL Database for free?”
	- click Apply offer.
- If you do not see it or do not want it, continue without changing anything here.
3. Set backup storage redundancy to LRS(IF you don’t find this No Problem)
   - Still on the Basics tab, find Backup storage redundancy.
   - Select Locally-redundant backup storage.
4. Project details
   - Subscription: choose your subscription.
   - Resource group: select lucky.
5. Database details
   - Database name: onepiecedb.
   - Want to use SQL elastic pool?: select No.
   - Workload environment: select Production.
   - Keep the default compute + storage (or adjust if you need).
6. Create the SQL server
- Under Server, click Create new.
- In the dialog:
  - Server name: onesqlserver123
  - Location: (Canada) Canada Central
- Authentication method: select Use SQL authentication
  - Server admin login: luckyadmin
  - Password: YourSecurePassword@123
  - Confirm password: same value
- Click OK to create and attach this server.
7. Networking
   - Click Next: Networking.
   - Connectivity method: choose Public endpoint.
   - Turn on Allow Azure services and resources to access this server.
   - add your client IP if you want to connect from your laptop.(means your ip address)
- Click Next: Security.
8. Security
  - Leave Defender, ledger, and other options at their defaults unless you specifically need them.
  - Click Next: Additional settings.
9. Additional settings
   - Data source: select None (empty database).
   - Collation: keep the default or choose SQL_Latin1_General_CP1_CI_AS.
- Leave the rest as default.
- Click Next: Tags (optional), then Next: Review + create.
10. Review and create
	- Wait for validation to pass.
	- Click Create.
- Azure will deploy:
	- Resource group: lucky (already created)
	- SQL server: onesqlserver123 in Canada Central
	- Database: onepiecedb
	- Backup redundancy: LRS
	- Authentication: SQL auth with luckyadmin / YourSecurePassword@123

### Phase 4: 
#### APP REGISTRATION IN AZURE CLOUD	
1. Create a Service Principal (App Registration)
1.	Go to Microsoft Entra ID → App registrations → New registration.
2.	Enter a name (example: lucky) → Register.
3.	Open the created app (lucky).
4.	Go to Certificates & secrets → New client secret → create and note down:
   - Application (client) ID
   - Directory (tenant) ID
   - Object ID
   - Secret value
   - Secret ID
   - Subscription ID (from Subscriptions page)
________________________________________
2. Assign Required Role to the Service Principal
  1.	Go to Subscriptions → select your subscription.
  2.	Open Access control (IAM).
  3.	Select Role assignments → Add role assignment.
  4.	Role: search and choose contributor → Next.
  5.	Members: + Select members → search for lucky → select → Next.
  6.	Conditions: leave default or recommended → Next.
  7.	Review → Review + assign.
#### INSTALL BELOW PLUGINS IN JENKINS
- Maven
- Pipeline stage viewer
- Sonarqube scanner
#### CONFIGURATIONS IN JENKINS
- Configure Maven in Jenkins (Tool Installation Setup)
- Go to Manage Jenkins → Global Tool Configuration.
- Scroll to the Maven section.
	- Add Maven
	- Name: maven
	- Version: Select a stable version (e.g., Apache Maven 3.9.6)
	- Install automatically: Enabled
- Click Apply → Save

- Configure SonarQube Scanner in Jenkins (Tool Installation Setup)
- Go to Manage Jenkins → Global Tool Configuration again.
- Scroll down to SonarQube Scanner installations.
	- Name: sonar-scanner #this is important we will use this pipeline
	- Version: SonarQube Scanner 7.3.0.5189
	- Install automatically: Enabled
- Click apply

#### CREDENTIALS MANAGEMENT IN JENKINS
- Azure cloud Credentials setup
  - Manage Jenkins>credentials>system>+Add credentials
  	- New credentials: kind : username and password 
  	- username: your client ID
  	- password: value 
  	- ID :azure-sp #this ID important we will use this pipeline

  - Manage Jenkins>credentials>system>+Add credentials
  	- New credentials: kind : secret text 
  	- secret : Directory(tenant ID)
  	- ID: azure-tenant #this ID important we will use this pipeline	
- Sonarqube Credentials setup
  - Manage Jenkins>credentials>system>+Add credentials
  	- New credentials: kind : secret text 
  	- secret : yoursonarqubetoken 
  	- ID: sonarqube-token #this ID important we will use this pipeline
- Configure the SonarQube server in Jenkins
	- Go to Manage Jenkins → Configure System
	- Scroll down to SonarQube servers
		- Click Add SonarQube
		- Fill it like this:
			- Name: sonar-server ← must match what you use in the pipeline
			- Server URL: http://4.206.81.78:9000/
		- Server authentication token:
			- Add credentials (kind: Secret text) with your SonarQube token
			- Select that credential here
	- save

### Phase 5: Argo CD setup in AKS cluster
  - ArgoCD: Argo CD is 100% Kubernetes-native. It is built specifically to deploy and manage applications inside Kubernetes clusters.
  - Think of Argo CD as: A GitOps controller that runs inside a Kubernetes cluster and continuously ensures the cluster matches the configuration stored in Git.

- Create a namespace in Kubernetes
```bash
az aks get-credentials --resource-group lucky --name lucky-aks-cluster11
kubectl create namespace argocd
kubectl get namespaces   #you will see argocd namespace created
```
- A namespace in Kubernetes is just a logical partition inside a cluster.
- Think of it as a folder inside your Kubernetes cluster where you keep related resources together.
- Paste the Official repo
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 
kubectl get svc -n argocd #you will see argocd services
```
- By default, the Argo CD API server is not exposed with an external IP. To access the API server do below
- This below command exposes the ArgoCD server to the internet by converting it into a LoadBalancer service and giving it a public IP.
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
- Copy the public IP of argocd-server using below
```bash
kubectl get svc -n argocd # you will see all services in argocd namespace
```
- For password of argocd server use below
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
- make a note of that password
- Browse the public ip which you copied with 443 as it is not https it show error but click on continue to site and navgate to argoCD UI
  - Username : admin
  - Password : which you copied from above command 

### Phase 6: pipelines
- we are going to write two pipelines
1.	CI-Pipeline-->name it as jenkins.ci or anyother
- Git checkout
- Maven package
- Sonarqube analysis
- Publish sonar report
- Login to Azure
- Build and Push your image to ACR
2.	CD-pipeline
- Checks CI pipeline is succesfull or not
- Gitops Deployment to aks using CD

### Phase 7: Monitoring using prometheus and Grafana
	
