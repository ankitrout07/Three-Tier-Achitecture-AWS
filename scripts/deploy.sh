#!/bin/bash
set -e

# Colors for output
GREEN='\033[0-9;32m'
NC='\033[0m' # No Color

echo -e "$${GREEN}Starting 3-Tier Architecture Deployment...$${NC}"

# 1. Initialize and Apply Terraform
echo -e "$${GREEN}Step 1: Initializing Cloud Infrastructure...$${NC}"
cd terraform
terraform init
terraform apply -auto-approve

# 2. Extract Outputs
EXTERNAL_ALB_URL=$(terraform output -raw external_alb_dns_name)

echo -e "$${GREEN}Successfully Deployed!$${NC}"
echo -e "Access your application at: http://$${EXTERNAL_ALB_URL}"
