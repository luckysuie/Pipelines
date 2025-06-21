# Pipeline 4: Deploying a .net application to aks using ACR and Jenkins
### Steps:
-----------
Fork the Repo to your GitHub : https://github.com/luckysuie/asp.net
1. Create a ubuntu vm with 2 cpus and 4 gb of Ram in azure with all ports open
2. Install Below
1. Git 
```bash
sudo apt update 
sudo apt install git -y
```
2. Install Java
```bash
sudo apt update 
sudo apt install open-jdk-21-jdk -y
```
3. Install Jenkins
```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
 https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
 https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
 /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
```

5. Install Az cli
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
7. Install docker
### Add Docker's official GPG key:
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### Add the repository to Apt sources:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Installing Docker packages
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### verify the installation
```bash
sudo docker run hello-world
```

6. Install Kubectl
```bash
Download the latest release with the command
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

7. Install Jenkins
```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install Jenkins -y
```
## Provisioning Resources
1. In the Ubuntu vm login to your account using below
```bash
az login --use-device-code
```
2. verify the account
```bash
az account show
```
4. create an resource group
```bash
az group create --name demo11 --location eastus
```
6. Create an ACR
```bash
az acr create --resource-group demo11 --name luckyregistry --sku Basic
```
8. create aks and attach to ACR
```bash
az aks create   --resource-group demo11   --name lucky-aks-cluster11   --node-count 1   --generate-ssh-keys   --attach-acr luckyregistry
```

10. create an app service registration
```bash
az ad sp create-for-rbac \
  --name "tf-spn-devops" \
  --role Contributor \
  --scopes /subscriptions/your-subscription-id
```
Imp: Note down the output whatever came like below
```bash
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "tf-spn-devops",
  "password": "generated-client-secret",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```
6.  Adding Jenkins user to the docker group
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```
This allows the Jenkins process to talk to Docker via the Unix socket at /var/run/docker.sock.

Jenkins setup and Running pipeline
--------------------------
1. Browse the publicip of VM with port 8080
2. Copy this /var/lib/jenkins/secrets/initialAdminPassword
3. Navigate to VM and type below
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
4. you will get the password copy and paste it in the browser then select insalled plugins
5. create username and password like admin for both user and password
6. Now click on start using Jenkins then you will see your Jenkins UI
7. navigate to Manage Jenkins--> plugins -->Available Plugins search for pipeline stage view and click install
8. Navigate to Manage Jenkins--> credentials -->add credentials then kind as secret text (whatever you noted previously on notepad)
```bash
ID			Purpose
azure-client-id		      Azure Service Principal App ID
azure-client-secret	    Azure SP password
azure-tenant-id		      Your Azure AD Tenant ID
azure-subscription-id	  Azure Subscription ID
```
Note: These Ids should exactly match your Jenkinsfile
10. Navigate to Jenkins dashboard click on New Item--> your pipeline name--->select pipeline --> ok

11. Navigate to your item move to Source code management section-->select Git --> paste your GitHub url then branch */main --> apply

12. Navigate your item and click on Build Now
13. You should see all your stages running

Testings:
----------
1. Navigate to your VM
2. configure your local kubectl client to connect and manage a specific Azure Kubernetes Service (AKS) cluster
```bash
az aks get-credentials --resource-group demo11   --name lucky-aks-cluster11
```
4. kubectl get all
5. Take the external IP and browse it you will see your application running in aks cluster
![Screenshot 2025-06-21 183553](https://github.com/user-attachments/assets/7f0e9bda-2ff4-49c9-9815-0685e5cb5ac5)
