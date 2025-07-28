# Git Installation
sudo apt update
sudo apt install git -y


#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update -y

# Install Java JDK 21
echo "Installing OpenJDK 21..."
sudo apt install openjdk-21-jdk -y

# Download and extract Apache Maven 3.8.9
echo "Downloading Maven 3.8.9..."
wget https://dlcdn.apache.org/maven/maven-3/3.8.9/binaries/apache-maven-3.8.9-bin.tar.gz

echo "Extracting Maven..."
tar -xvzf apache-maven-3.8.9-bin.tar.gz
mv apache-maven-3.8.9 maven

# Set Maven environment variables (temporary for current shell)
echo "Setting Maven environment variables..."
export MAVEN_HOME=/home/azureuser/maven
export PATH=$MAVEN_HOME/bin:$PATH

# Append environment variables to .bashrc for persistence
echo "Adding Maven environment variables to ~/.bashrc..."
echo "export MAVEN_HOME=/home/azureuser/maven" >> ~/.bashrc
echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> ~/.bashrc

# Apply changes
source ~/.bashrc


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
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install -y trivy



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
sudo systemctl status jenkins
docker --version
trivy --version
az --version
kubectl version --client
mvn -v
