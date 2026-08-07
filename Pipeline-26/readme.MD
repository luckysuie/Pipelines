## Deploying a Two-Tier Spring Boot Application on Azure Using Jenkins CI/CD, Azure SQL, and Key Vault

- Fork this reository and clone it to your local machine. URL: https://github.com/luckysuie/quickstart-spring-data-jdbc-sql-server 

### Create a resource group and a virtual machine in Azure
```bash
az group create --name jenkins-rg --location CentralIndia
az vm create --resource-group jenkins-rg --name jenkins-vm --image Canonical:ubuntu-24_04-lts:server:latest --size Standard_D2s_v3 --admin-username azureuser --admin-password AdminPassword123! --public-ip-address-dns-name jenkins-vm-dns --output json
az vm open-port --resource-group jenkins-rg --name jenkins-vm --port '*'
```
- Login to VM using ssh and install Jenkins and Azure CLI on the VM.
```bash
ssh azureuser@your-vm-ip
```

### Jenkins Installation on Ubuntu 24.04 LTS
```bash
sudo apt update
sudo apt install openjdk-21-jdk -y # Jenkins needs Java to run
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
```

### Install Azure CLI on the Jenkins VM

```bash
sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```

### Login to your azure account
```bash
az login --use-device-code
```


### create a service principal and store the credentials in the jenkins as a secret for the jenkins to access the azure resources
```bash
az ad sp create-for-rbac --name "jenkins-sp" --role contributor --scopes /subscriptions/your-subscription-id --sdk-auth
```
- Note : Esure to copy the output of the above command and store it in a safe place as it contains the credentials for the service principal.

- Browse public ip with port 8080 you should see your Jenkins login page---> http://yourvmip:8080/
- Copy this /var/lib/jenkins/secrets/initialAdminPassword which shown in your Jenkins UI
- Navigate to VM and type below sudo cat /var/lib/jenkins/secrets/initialAdminPassword
- you will get the password copy and paste it in the browser then select insalled plugins
- create username and password like admin for both user and password
- Now click on start using Jenkins then you will see your Jenkins UI
- Manage jenkins>Plugins>Available Plugins search for pipeline stage view and install
- Manage jenkins>Plugins>Available Plugins search for maven integration and install

#### configure Maven in Jenkins
- Manage jenkins>Tools>Maven Tool
- Maven Installations
- Name: maven
- click apply

### Azure cloud credentials configuration
- Manage Jenkins>credentials>system>+Add credentials
- New credentials: kind : username and password
    - username: your client ID
    - password: value 
    - ID :azure-sp

- Manage Jenkins>credentials>system>+Add credentials
    - New credentials: kind : secret text as shown below
    - secret : Directory(tenant ID)
    - ID: azure-tenant


- Navigate to Jenkins dashboard click on New Item--> your pipeline name--->select pipeline --> ok
- Navigate to your item move to Source code management section-->select Git --> paste your GitHub url then branch */master --> apply


## Create Azure SQL Server and Database
```bash
az sql server create --name jenkins-sqlserver7894 --resource-group jenkins-rg --location CentralIndia --admin-user adminuser --admin-password AdminPassword123!
az sql db create --resource-group jenkins-rg --server jenkins-sqlserver7894 --name jenkinsdb --service-objective S0
az sql server firewall-rule create --resource-group jenkins-rg --server jenkins-sqlserver7894 --name AllowYourIP --start-ip-address  49.43.221.62 --end-ip-address  49.43.221.62
az sql server firewall-rule create --resource-group jenkins-rg --server jenkins-sqlserver7894 --name AllowAzureServices --start-ip-address  0.0.0.0 --end-ip-address  0.0.0.0
```


### Create Azure Key Vault
```bash
az keyvault create --name luckykeyvault123 --resource-group jenkins-rg --location CentralIndia
```

### Assign Key Vault Administrator role to the signed-in user for the Key Vault
```bash
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)  ## Get the object ID of the signed-in user and store it in a variable
KV_ID=$(az keyvault show --name luckykeyvault123 --resource-group jenkins-rg --query id -o tsv)  ## Get the resource ID of the Key Vault and store it in a variable
az role assignment create --assignee $USER_OBJECT_ID --role "Key Vault Administrator" --scope $KV_ID  ## Assign the Key Vault Administrator role to the signed-in user for the Key Vault
```


### Store the database connection string, username, and password as secrets in Azure Key Vault
```bash
az keyvault secret set --vault-name luckykeyvault123 --name "spring-datasource-url" --value "jdbc:sqlserver://jenkins-sqlserver7894.database.windows.net:1433;database=jenkinsdb;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
az keyvault secret set --vault-name luckykeyvault123 --name "spring-datasource-username" --value "adminuser"
az keyvault secret set --vault-name luckykeyvault123 --name "spring-datasource-password" --value "AdminPassword123!"
```

- Note dont chagne the names of the secrets in the key vault as they are used in the spring boot application to access the database connection string, username and password.


### create app service plan and web app
```bash
az appservice plan create --name jenkins-app-service-plan --resource-group jenkins-rg --sku B1 --is-linux
az webapp create --name jenkins-webapp --resource-group jenkins-rg --plan jenkins-app-service-plan --runtime "JAVA|11-java11"
az webapp config set --name jenkins-webapp --resource-group jenkins-rg --linux-fx-version "JAVA|17-java17"  ## configure the web app to use Java 17 runtime
```


- this command configures your deployed Spring Boot application to run using Azure-specific settings and tells it which Azure Key Vault to use.
```bash
az webapp config appsettings set --name jenkins-webapp --resource-group jenkins-rg --settings AZURE_KEYVAULT_ENDPOINT=https://luckykeyvault123.vault.azure.net/
```

- This command enables a System Assigned Managed Identity for the Azure App Service, allowing it to securely authenticate with Azure services like Key Vault without storing credentials.
```bash
az webapp identity assign --name jenkins-webapp --resource-group jenkins-rg 
```

## Assign the Key Vault Secrets User role to the web app's managed identity for accessing secrets in Key Vault
```bash
APP_PRINCIPAL_ID=$(az webapp show --name jenkins-webapp --resource-group jenkins-rg --query identity.principalId -o tsv)
KV_ID=$(az keyvault show --name luckykeyvault123 --resource-group jenkins-rg --query id -o tsv)
az role assignment create --assignee-object-id $APP_PRINCIPAL_ID --assignee-principal-type ServicePrincipal --role "Key Vault Secrets User" --scope $KV_ID
```

#### Assigns the Key Vault Secrets User role to the Jenkins service principal, allowing it to securely read secrets from the specified Azure Key Vault.
```bash
az role assignment create --assignee "your-app-registration-client-id" --role "Key Vault Secrets User" --scope "/subscriptions/your-subscription-id/resourceGroups/jenkins-rg/providers/Microsoft.KeyVault/vaults/luckykeyvault123"
```

### Writing the Jenkins pipeline script to build and deploy the Spring Boot application to Azure App Service
- open the cloned repository in the Visual Studio Code and create a new file named Jenkinsfile if already present and you wanna try your own delete it and start from scratch by writing the below stages

#### Stages
- Git checkout: This stage checks out the source code from the GitHub repository.
- Login to Azure: This stage logs in to Azure using the service principal credentials stored in Jenkins.
- maven validate: This stage runs the Maven validate command to ensure that the project is correctly configured.
- maven compile: This stage runs the Maven compile command to compile the source code of the Spring Boot application.
- maven test: This stage runs the Maven test command to execute unit tests.
- maven package: This stage runs the Maven package command to package the application into a JAR file.
- Deploy to Azure App Service: This stage deploys the packaged JAR file to the Azure App Service using the Azure CLI.

### Pipeline Script
```bash
pipeline {
    agent any

    tools {
        maven 'maven' // Ensure that Maven is installed and configured in Jenkins
    }

    environment {
        RESOURCE_GROUP = 'jenkins-rg'
        WEB_APP_NAME = 'jenkins-webapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    branch: 'master',
                    url: 'https://github.com/luckysuie/quickstart-spring-data-jdbc-sql-server.git'
                )
            }
        }

        stage('Login to Azure') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'azure-sp',
                        usernameVariable: 'AZURE_USERNAME',
                        passwordVariable: 'AZURE_PASSWORD'
                    ),
                    string(
                        credentialsId: 'azure-tenant',
                        variable: 'TENANT_ID'
                    )
                ]) {
                    script {
                        echo 'Logging into Azure Container Registry...'
                        sh '''
                            az login --service-principal -u "$AZURE_USERNAME" -p "$AZURE_PASSWORD" --tenant "$TENANT_ID"
                        '''
                    }
                }
            }
        }

        stage('Maven validate') {
            steps {
                echo 'Validating the Maven project...'
                sh 'mvn validate'
            }
        }

        stage('Maven compile') {
            steps {
                echo 'Compiling the application...'
                sh 'mvn compile'
            }
        }

        stage('Maven test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }

        stage('Maven package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
        }

        stage('Deploy to Azure Web App') {
            steps {
                echo 'Deploying the application to Azure Web App...'
                sh '''
                    az webapp deploy --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --src-path target/*.jar --type jar
                '''
            }
        }
    }
}
```

### push the changes into repository
```bash
git add .
git commit -m "Added Jenkinsfile for CI/CD pipeline"
git push origin master
```
