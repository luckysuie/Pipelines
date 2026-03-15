  ## End-to-End CI/CD Deployment of a Java Spring Boot Application to Azure App Service using Azure DevOps, Key Vault, and Azure SQL
----
TECH stack:
---
1. Azure Keyvault
2. Azure sql Database
3. Azure Web app(Java)
4. Maven
5. Azure DevOps pipeline

### Architecture Diagram





#### Project Setup Steps
1. Create a New Project in Azure DevOps
  - Navigate to the Azure DevOps portal.
  - Create a New Project with your preferred name.
2. Import the Repository
    - Go to Repos in the project.
    - Click the top dropdown → Import Repository.
    - Use the following repository URL:
- Repository: https://github.com/luckysuie/quickstart-spring-data-jdbc-sql-server
- 
#### Azure Resource Setup
3. Create Required Resources in Azure Portal
- Navigate to the Azure Portal and create the following resources:
  - Azure SQL Database
  - Azure Key Vault
    - Suggested name: luckykeyvault123
- If you change the name, update it in the application.properties file in the repository.

4. Configure Key Vault Permissions
   - Open the created Key Vault.
   - Navigate to IAM (Access Control).
   - Assign the role Key Vault Administrator to your user account.

5. Store Database Credentials in Key Vault
- Add the following secrets inside Key Vault:
- Secret Name: spring-datasource-url
```bash
jdbc:sqlserver://webserver12.database.windows.net:1433;database=OnepieceDatabase;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
```
- Secret Name: spring-datasource-username : LakshmiNarayana@webserver12
(Use your actual login username and SQL server name)
- Secret Name: spring-datasource-password : <your_actual_password>

### Web Application Configuration
6. Create Azure Web App
   - Create a new Azure App Service (Web App) with the following configuration: Runtime Stack: Java 21

7. Configure Startup Command
- Navigate to the Web App → Configuration → Stack Settings and set the Startup Command: java -jar /home/site/wwwroot/target/demo-0.0.1-SNAPSHOT.jar

8. Enable Managed Identity
  - Open your Web App.
  - Navigate to Identity.
  - Enable System Assigned Managed Identity.

9. Grant Web App Access to Key Vault
- Navigate to Key Vault → Access Control (IAM) and perform the following:
  - Click Add Role Assignment
  - Select the role Key Vault Secrets User
  - Assign access to: Managed Identity
  - Select your App Service (example: piratewebapp145)
  - Click Save


CI Pipeline Setup in Azure DevOps
6. Configure the Build (CI) Pipeline
  - Navigate to your Azure DevOps Project and perform the following steps:
1. Create Service Connection
  - Go to Project Settings → Service Connections.
  - Create a new Service Connection to connect your Azure account.
  - Authorize the connection so Azure DevOps can deploy resources.

2. Create a New Pipeline
- Navigate to Pipelines → New Pipeline.
- Select your imported repository.
- Choose Classic Editor.
- Select the Maven template.

3. Configure the Agent
- Under Pipeline → Agent Job 1 configure the following:
  - Agent Pool: Azure Pipelines
  - Agent Specification: Ubuntu 24.04

4. Configure Build Tasks
- Perform the following configurations in the pipeline tasks:
1. Java Tool Installer
   - Add Java Tool Installer above the pom.xml Maven task.
   - This ensures the required Java version is available for the build.
3. Maven Task Configuration
- In Maven Goals, set the value to: clean package -DskipTests
- This command will:
  - Clean the previous build files
  - Package the application
  - Skip unit tests during the build process

4. Keep Remaining Settings Default
   - No additional changes are required.
   - Keep the remaining configuration as default.

5. Run the Pipeline
  - Click Save.
  - Select Save and Queue.
  - Click Run to start the pipeline.

6. Pipeline Output
   - The CI Pipeline will run successfully.
   - After completion, it will generate a Build Artifact (JAR file) which will be used later in the Release Pipeline for deployment to Azure App Service.


### Release Pipeline – Steps
1. Create a New Release
- Navigate to Pipelines → Releases in Azure DevOps.
- Click New Release.
- From the templates on the top right, select Azure App Service Deployment.
2. Add Artifact
  - Click Add an artifact.
  - Select the project and choose the latest successful run of the build pipeline.
  - Click Add.
3. Configure the Deployment Stage
- Navigate to Stage → 1 Job → 1 Task in the pipeline UI and configure the following:
  - Stage Name: Deployment Stage
  - Azure Subscription: Authorize your subscription using the dropdown
  - App Type: Web App on Linux
  - App Service Name: Select the App Service (e.g., piratewebapp145) from the dropdown
  - Startup Command: java -jar /home/site/wwwroot/target/demo-0.0.1-SNAPSHOT.jar
4. Configure the Agent
- Under Run on Agent section:
- Agent Pool: Azure Pipelines
- Agent Specification: Ubuntu 22.04
5. Select the Deployment Package
  - In Deploy to Azure App Service, locate the Package or Folder field.
  - Click the three dots (…) to browse artifacts.
  - Open the drop folder to view the build artifacts.
  - Navigate inside the folder and locate the .jar file.
  - Select the JAR file and click OK.
  - This sets the correct JAR path for deployment.
6. Save and Run the Release
  - Click Save after configuration.
  - Create or trigger a new release.
  - The pipeline will deploy the application to Azure App Service, and the application will run successfully.
