#!/bin/bash
set -e

# Base packages
sudo apt update -y
sudo apt install -y git openjdk-21-jdk software-properties-common apt-transport-https wget curl snapd

# Git
git --version

# Jenkins
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y jenkins
sudo systemctl enable --now jenkins

#!/bin/bash

# Docker install + enable docker without sudo + Jenkins user docker access
sudo apt update -y
wget -O docker.sh https://get.docker.com/
sudo sh docker.sh

sudo groupadd -f docker
sudo usermod -aG docker "$USER"
sudo usermod -aG docker jenkins

sudo systemctl restart docker
sudo systemctl restart jenkins
