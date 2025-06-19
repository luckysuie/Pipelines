# 🚀 Pipeline 2: Deploying Java Spring Boot App to Tomcat using Azure DevOps
This pipeline demonstrates how to automate the build and deployment of a Java Spring Boot application (.war file) to a Tomcat server using Azure DevOps.

## 📁 Step 1: Azure DevOps Project Setup
Create a new project in your Azure DevOps organization.

Import your GitHub repository (or push your local repo to Azure Repos if needed).

## ⚙️ Step 2: Configure CI Pipeline (Build)
The CI (Continuous Integration) pipeline handles building the .war file and publishing it as an artifact.

Tasks to include in your CI YAML or Classic pipeline:

✅ Install Java (Use Java Tool Installer task or specify in YAML)

⚙️ Run Maven Package

mvn clean package
📦 Copy Artifacts

Copy the generated .war file from target/ directory.

📤 Publish Artifacts

Use the PublishBuildArtifacts@1 task.

## 🚀 Step 3: Configure CD Pipeline (Release)
The CD (Continuous Deployment) pipeline handles deploying the .war file to a Tomcat server.

🔧 Pre-requisite:
Create a Virtual Machine (VM) in Azure and install/configure Apache Tomcat.

Ensure Tomcat Manager is enabled with proper credentials for deployment.

🎯 Release Pipeline Setup:
Go to Pipelines > Releases.

Create a new release pipeline.

Add Artifact: Link the artifact from the CI pipeline.

Add a Stage:

Select a task: Deploy to Tomcat

Provide the Tomcat server URL, credentials, and path to .war file.

Save and Create Release.

## Tomcat Configuration in VM
1. sudo apt update
2. sudo apt install openjdk-17-jdk -y
3. wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.105/bin/apache-tomcat-9.0.105.tar.gz
4. tar -xvzf apache-tomcat-9.0.105.tar.gz
5. ls
6. mv apache-tomcat-9.0.105 tomcat
7. cd tomcat
8. cd bin/
9. ls
10. sh startup.sh---------------------------> you will see you tomcat server running by browsing http://publicip:8080
11. vi ~/tomcat/webapps/manager/META-INF/context.xml-----------------------> Delete the <valve section there 
12. vi ~/tomcat/conf/tomcat-users.xml paste the Below in users section and save and exit
    ```bash
    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <role rolename="manager-status"/>
    <role rolename="admin-gui"/>
    <user username="admin" password="admin123" roles="manager-gui,manager-script,manager-status,admin-gui"/>
