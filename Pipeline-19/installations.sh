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

# Docker
wget -O docker.sh https://get.docker.com/
sudo sh docker.sh
sudo usermod -aG docker jenkins
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

sudo groupadd -f docker
sudo usermod -aG docker "$USER"
sudo systemctl restart docker
sudo systemctl restart jenkins

# SonarQube (Docker)
docker pull sonarqube
docker run -d --name sonarqube -p 9000:9000 sonarqube

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# kubectl
sudo snap install --classic kubectl

# Install argocd
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
argocd version

# Prometheus (binary under /opt/prometheus)
sudo apt update -y
cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
sudo tar -xvzf prometheus-3.5.0.linux-amd64.tar.gz
sudo rm -f prometheus-3.5.0.linux-amd64.tar.gz
sudo rm -rf /opt/prometheus
sudo mv prometheus-3.5.0.linux-amd64 /opt/prometheus
sudo mkdir -p /opt/prometheus/data
cd ~

sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/opt/prometheus/prometheus \
  --config.file=/opt/prometheus/prometheus.yml \
  --storage.tsdb.path=/opt/prometheus/data

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# Grafana
sudo apt-get update -y
sudo add-apt-repository -y "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install -y grafana
sudo systemctl enable --now grafana-server
echo "Services:"
echo "  Jenkins    -> http://<VM-IP>:8080"
echo "  SonarQube  -> http://<VM-IP>:9000"
echo "  Prometheus -> http://<VM-IP>:9090"
echo "  Grafana    -> http://<VM-IP>:3000"
echo " Docker verify without sudo"
docker --version
docker ps
