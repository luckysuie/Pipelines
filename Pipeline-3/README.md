# 🚀 Pipeline 3: Dockerizing Java Spring Boot App and Deploying to AKS using Azure DevOps

This pipeline explains how to containerize a Java Spring Boot application using Docker and deploy it to Azure Kubernetes Service (AKS) via a YAML pipeline in Azure DevOps.

---

## 🎯 Objective

Build a Docker image of a Java Spring Boot application, push it to Docker Hub, and deploy it to an AKS cluster using an Azure DevOps pipeline.

---

## ⚙️ Pre-requisites

- An existing **Azure Kubernetes Service (AKS)** cluster.
- A **Docker Hub** account for pushing the image.
- Permissions to create a **service connection** in Azure DevOps.

---

## 🛠️ Step-by-Step Instructions

### 🔧 Step 1: Set Up Azure DevOps Project

1. Navigate to [Azure DevOps](https://dev.azure.com/) and create a new project.
2. Go to **Repos** and import the desired repository.
3. Navigate to **Project Settings > Service connections**, and create a service connection to your Azure account.
4. Create a **Docker registry service connection** (Docker Hub).

---

### 📝 Step 2: Create YAML Pipeline

Navigate to **Pipelines > New Pipeline** and define the YAML with steps for:

#### 📦 1. Docker Build and Push

- Build the Docker image from your Java Spring Boot app.
- Tag and push it to your Docker Hub repository.

#### 🚀 2. Deploy to AKS Cluster

- Use `kubectl` to deploy the pushed Docker image to your AKS cluster.
- Ensure you reference your AKS credentials through the service connection.

---

## ✅ Outcome

Once the pipeline runs:


- A Docker image is built and pushed to your Docker Hub.
- The image is then pulled by AKS and deployed as a running container.
- You can access your Java Spring Boot app via the AKS service endpoint

- ![Screenshot 2025-06-19 204716](https://github.com/user-attachments/assets/168fd033-dbe4-44bc-9863-37c0e5f1cd2e)
