# Project Bedrock - AWS EKS Retail Store Deployment

## Overview

This project deploys a complete AWS infrastructure including VPC, EKS cluster, S3 bucket with Lambda integration, and the AWS Retail Store Sample Application using Terraform and CI/CD pipelines.

---

## 📋 Resource Tagging

All infrastructure resources are tagged with:

```
Project: barakat-2025-capstone
```

---

## 🔗 Git Repository

**Repository URL:** [https://github.com/your-username/project-bedrock](https://github.com/your-username/project-bedrock)

The repository contains:
- `terraform/` - Infrastructure as Code (Terraform)
- `.github/workflows/` - CI/CD Pipeline YAML
- `lambda/` - Lambda function code for S3 event processing
- `kubernetes/` - Helm values and Kubernetes manifests

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    AWS Cloud                                     │
│                                   us-east-1                                      │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC (10.0.0.0/16)                                 │  │
│  │                                                                           │  │
│  │  ┌─────────────────────────┐    ┌─────────────────────────┐              │  │
│  │  │   Public Subnet 1       │    │   Public Subnet 2       │              │  │
│  │  │   (10.0.1.0/24)         │    │   (10.0.2.0/24)         │              │  │
│  │  │   us-east-1a            │    │   us-east-1b            │              │  │
│  │  │  ┌─────────────────┐    │    │  ┌─────────────────┐    │              │  │
│  │  │  │  NAT Gateway    │    │    │  │  NAT Gateway    │    │              │  │
│  │  │  └─────────────────┘    │    │  └─────────────────┘    │              │  │
│  │  └─────────────────────────┘    └─────────────────────────┘              │  │
│  │           │                              │                                │  │
│  │  ┌────────▼────────────────┐    ┌───────▼─────────────────┐              │  │
│  │  │   Private Subnet 1      │    │   Private Subnet 2      │              │  │
│  │  │   (10.0.10.0/24)        │    │   (10.0.20.0/24)        │              │  │
│  │  │   us-east-1a            │    │   us-east-1b            │              │  │
│  │  │  ┌─────────────────┐    │    │  ┌─────────────────┐    │              │  │
│  │  │  │  EKS Node       │    │    │  │  EKS Node       │    │              │  │
│  │  │  │  (t3.medium)    │    │    │  │  (t3.medium)    │    │              │  │
│  │  │  └─────────────────┘    │    │  └─────────────────┘    │              │  │
│  │  └─────────────────────────┘    └─────────────────────────┘              │  │
│  │                                                                           │  │
│  │  ┌─────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                      EKS Cluster                                    │ │  │
│  │  │  ┌───────────────────────────────────────────────────────────────┐  │ │  │
│  │  │  │                  Retail Store App (Helm)                      │  │ │  │
│  │  │  │  ┌─────┐ ┌─────────┐ ┌──────────┐ ┌───────┐ ┌────────┐       │  │ │  │
│  │  │  │  │ UI  │ │ Catalog │ │ Checkout │ │ Carts │ │ Orders │       │  │ │  │
│  │  │  │  │(LB) │ │ (MySQL) │ │ (Redis)  │ │       │ │(Postgres)      │  │ │  │
│  │  │  │  └─────┘ └─────────┘ └──────────┘ └───────┘ └────────┘       │  │ │  │
│  │  │  └───────────────────────────────────────────────────────────────┘  │ │  │
│  │  └─────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                         S3-Lambda Flow                                       ││
│  │                                                                              ││
│  │  ┌─────────────────┐     S3 Event      ┌─────────────────┐                  ││
│  │  │   S3 Bucket     │ ─────────────────▶│  Lambda Function │                  ││
│  │  │ (bedrock-assets)│  ObjectCreated    │ (asset-processor)│                  ││
│  │  └─────────────────┘                   └─────────────────┘                  ││
│  │                                               │                              ││
│  │                                               ▼                              ││
│  │                                      ┌─────────────────┐                    ││
│  │                                      │  CloudWatch Logs │                    ││
│  │                                      └─────────────────┘                    ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Deployment Guide

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- Helm 3.x

### How to Trigger the Pipeline

1. **Push to main branch** - The GitHub Actions pipeline automatically triggers on push to `main`
2. **Manual trigger** - Go to GitHub Actions → Terraform → Run workflow

### Pipeline Stages

1. `terraform init` - Initialize Terraform
2. `terraform plan` - Preview changes
3. `terraform apply` - Deploy infrastructure
4. Generate `grading.json` - Export outputs for grading

### Local Deployment

```bash
# Clone the repository
git clone https://github.com/your-username/project-bedrock.git
cd project-bedrock/terraform

# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Initialize and apply
terraform init
terraform apply
```

---

## 🌐 Retail Store Application URL

**Live Application:** Access the running Retail Store at the URL provided in the Terraform output:

```bash
terraform output retail_store_url
```

**Current URL:** `http://ab5460e06811247ec8b2ec8fcf6683f7-1310927593.us-east-1.elb.amazonaws.com`

---

## 🔐 Grading Credentials

### Developer User: `bedrock-dev-view`

This IAM user has:
- **ReadOnlyAccess** to AWS Console
- **S3 PutObject** permission for the assets bucket
- **EKS View** access to the Kubernetes cluster

To retrieve credentials:

```bash
# Access Key ID
terraform output developer_access_key_id

# Secret Access Key (sensitive)
terraform output -raw developer_secret_access_key
```

---

## 📊 Grading Data

The `grading.json` file is generated from Terraform outputs and committed to the repository root.

### Generate/Update grading.json

```bash
cd terraform
terraform output -json > ../grading.json
```

### Contents

The grading.json includes:
- VPC ID and CIDR
- Subnet IDs (public and private)
- NAT Gateway IDs
- EKS Cluster name and endpoint
- Retail Store URL
- S3 Bucket name
- Lambda Function name
- Developer credentials

---

## 📁 Repository Structure

```
project-bedrock/
├── .github/
│   └── workflows/
│       └── terraform.yml      # CI/CD Pipeline
├── kubernetes/
│   └── helm-values.yaml       # Helm chart values
├── lambda/
│   └── index.py               # Lambda function code
├── scripts/
│   └── deployapp.sh           # Deployment helper script
├── terraform/
│   ├── main.tf                # Terraform configuration
│   ├── provider.tf            # AWS & Kubernetes providers
│   ├── variables.tf           # Input variables
│   ├── output.tf              # Output definitions
│   ├── vpc.tf                 # VPC resources
│   ├── eks.tf                 # EKS cluster
│   ├── iam.tf                 # IAM roles and policies
│   ├── s3.tf                  # S3 bucket
│   ├── lambda.tf              # Lambda function
│   ├── kubernetes.tf          # K8s resources & Helm
│   └── developer-access.tf    # Developer IAM user
├── grading.json               # Terraform outputs for grading
└── README.md                  # This file
```

---

## 📝 Notes

- EKS nodes are deployed in private subnets with NAT Gateway access
- The Retail Store UI is exposed via AWS LoadBalancer
- S3 bucket has versioning and encryption enabled
- Lambda function processes S3 upload events
- All resources are tagged with `Project: barakat-2025-capstone`