# Enterprise GitOps & K8s Architecture 🚢🏗️

![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC.svg?logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5.svg?logo=kubernetes)
![AWS EKS](https://img.shields.io/badge/AWS-EKS-FF9900.svg?logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-Automated-2088FF.svg?logo=github-actions)

## Overview
This repository serves as a **Capstone Project** demonstrating a modern, enterprise-grade GitOps workflow. It contains the complete lifecycle of a containerized microservice—from the application code to the underlying AWS infrastructure required to run it in a highly available state.

The goal of this project is to showcase production-level DevOps principles: **Infrastructure as Code (IaC)**, **Container Orchestration**, and **Continuous Integration (CI)**.

## 🏗️ Architecture Layers

### 1. The Microservice (Python/FastAPI)
* A lightweight API (`main.py`) designed for fast horizontal scaling.
* Packaged using a production-ready `Dockerfile` to ensure environment consistency.

### 2. Infrastructure as Code (Terraform)
* Located in `/terraform`.
* Automates the provisioning of an **AWS EKS (Elastic Kubernetes Service)** cluster.
* Configures the underlying Virtual Private Cloud (VPC), subnets, and security groups to ensure network isolation.

### 3. Container Orchestration (Kubernetes)
* Declarative deployment instructions (`deployment.yaml`).
* Enforces **High Availability (HA)** by maintaining multiple replicas of the container.
* Utilizes a `LoadBalancer` Service to manage ingress traffic efficiently.

### 4. Continuous Integration (GitHub Actions)
* Located in `.github/workflows/ci.yaml`.
* Automatically triggers on every push to the `main` branch.
* Verifies environment stability, checks dependencies, and builds the Docker image to ensure the code is deployment-ready before reaching production.

## 👨‍💻 Author
**Muathaf**
* Dual MS in Artificial Intelligence & Information Technology
* *Actively seeking Cloud, Junior DevOps, and AI Engineering roles in the GCC.*
