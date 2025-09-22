# Pipeline-6: Deploying a Nodejs+Mongo DB application to azure app service using Azure DevOps
### Steps:
---------
1. Navigate to Azure DevOps and create a new project named pipeline-6
2. Navigate to repos
3. Click on Import and import this repo https://github.com/Azure-Samples/msdocs-nodejs-mongodb-azure-sample-app
## Architecture Diagram
<img width="888" height="466" alt="image" src="https://github.com/user-attachments/assets/96c236e7-77a3-4da8-8b34-9517489eb6e1" />
4. Navigate to portal and create azure app service
- select webapp+database
- Enter the name
- select database mongodb
- Runtime Stack: Node - 20-lts
- SKU and size: Basic
- Navigate to pipelines and start writing the pipeline for

## CI Continous Integration
- Node js 20 installation
- npm install command
- copy the files which are created by above task
- Make the above files as Zip
- publish the artifact to the container
## Continous Deployment
- Deploy to azure app service

![Screenshot 2025-06-24 232743](https://github.com/user-attachments/assets/9f2a792d-8748-4743-a663-0e49a41e0218)
