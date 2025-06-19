# 🚀 Pipeline 1: Deploying Java Spring Boot App to Azure App Service using Azure DevOps

This pipeline demonstrates how to deploy a Java Spring Boot application to Azure App Service using Azure DevOps.

---

## 🎯 Objective

Deploy a Java Spring Boot application to Azure App Service via Azure DevOps.

- **Repository**: [Java Spring Boot App](https://github.com/luckysuie/Java-springboot)

---

## ⚙️ Step 1: Continuous Integration (CI)

- Import the GitHub repository into Azure DevOps.
- Create a CI pipeline using:
  - **YAML-based pipeline**  
    _or_
  - **Classic Editor** (drag-and-drop UI)
- Tasks included in the pipeline:
  - Java setup
  - Maven build
  - Publish the build artifacts

---

## 🚀 Step 2: Continuous Deployment (CD)

- **Pre-requisite**: Create an **Azure App Service** instance in your Azure subscription.
- In Azure DevOps:
  - Go to **Releases**
  - Create a **new release pipeline**
  - **Add artifact** from the CI pipeline
  - **Add a stage** to deploy to **Azure App Service**
  - Configure Azure subscription and app service details
  - Save and **Create a Release**

---

## ✅ Outcome

Once triggered:

- The application is built and artifacts are published in the CI phase.
- The CD pipeline picks up the artifact and deploys it to Azure App Service.
- You can view the deployed app in your browser via the App Service URL.

---

## ✨ Experience

> Overall, my experience with this pipeline was satisfying. Seeing my webpage successfully deployed gave me a great sense of accomplishment. A simple start, but a good start!
![Screenshot 2025-06-17 213936](https://github.com/user-attachments/assets/e304756c-d3aa-42a0-a598-cc367c88e846)
