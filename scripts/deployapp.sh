#!/bin/bash
# =============================================================================
# Deploy Retail Store Sample App to EKS
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Retail Store Sample App Deployment ===${NC}"

# Variables
CLUSTER_NAME="project-bedrock-cluster"
REGION="us-east-1"
NAMESPACE="retail-app"

# Step 1: Configure kubectl
echo -e "${YELLOW}Step 1: Configuring kubectl...${NC}"
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Step 2: Create namespace
echo -e "${YELLOW}Step 2: Creating namespace...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Step 3: Add Helm repository
echo -e "${YELLOW}Step 3: Adding Helm repository...${NC}"
helm repo add eks-charts https://aws.github.io/eks-charts
helm repo update

# Step 4: Deploy the retail-store-sample-app
echo -e "${YELLOW}Step 4: Deploying retail-store-sample-app...${NC}"

# Clone and deploy the retail store sample app
if [ ! -d "retail-store-sample-app" ]; then
    git clone https://github.com/aws-containers/retail-store-sample-app.git
fi

cd retail-store-sample-app

# Deploy using Helm
helm upgrade --install retail-store ./deploy/kubernetes/charts/retail-store \
    --namespace $NAMESPACE \
    --values ../kubernetes/helm-values.yaml \
    --wait \
    --timeout 10m

# Step 5: Verify deployment
echo -e "${YELLOW}Step 5: Verifying deployment...${NC}"
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE

# Get the UI service URL
echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo -e "${GREEN}Getting the application URL...${NC}"
kubectl get svc -n $NAMESPACE ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo -e "${GREEN}Use the above URL to access the Retail Store application${NC}"