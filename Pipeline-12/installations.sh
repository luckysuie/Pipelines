# Git Installation
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
sudo usermod -aG docker jenkins   #adds the user jenkins to the docker group, allowing Jenkins to run Docker commands without using sudo
sudo systemctl restart jenkins # it will restart the jenkins



#trivy installation
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y


#Azure CLI Installation
sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash


#kubectl Installation
sudo apt update
sudo snap install kubectl --classic


#Installations checking
git --version
java --version
jenkins --version
docker --version
trivy --version
az --version
kubectl version --client
