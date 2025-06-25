# Pipeline-7: Deploying a asp.net application with SonarQube to azure app service using Azure DevOps
### Steps:
---------
1. Navigate to Azure DevOps and create a new project named pipeline-7
2. Navigate to repos
3. Click on Import and import this repo https://github.com/luckysuie/web-asp-dontnet
4. Open sonarcloud.io and login into your account using GitHub
5. Create a organization and create a project named dotnetanalysis in that organization
6. Navigate to my account--> security-->Generate Token
Note down the below
- project name
- project key
- Token

7. Navigate to Azure DevOps and move project settings and create a service connection for sonar cloud
- search SonarQube and provide the necessary details
- you should see you connection successful

8. Navigate to portal and create azure app service
- select webapp
- Enter the name
- Runtime Stack: .NET 8(LTS)
- Operating system : windows
- Region: Canada central

5. Navigate to pipelines and start writing the pipeline for

## CI Continuous Integration
-----------
1. Install NuGet
2. Restore packages
3. Prepare SonarCloud
4. Build the project
5. Run SonarCloud Analysis
6. Publish SonarCloud Results
7. Publish Web App
8. Publish Build Artifact

## CD Continuous Deployment
----------
1. Download the artifact
2. Deploy to Azure app service

<h2 align="center">Succesfull Pipeline</h2>

![Screenshot 2025-06-25 113003](https://github.com/user-attachments/assets/b33bf253-88d2-4dfe-8379-37682a5d34ac)

<h2 align="center">Sonar Analysis</h2>

![Screenshot 2025-06-25 124811](https://github.com/user-attachments/assets/0a83625a-4a64-4cd9-9978-8663944bc990)
