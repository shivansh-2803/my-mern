#!/bin/bash

echo "🚀 Creating EKS Cluster..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run: aws configure"
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Create all infrastructure
echo "🏗️ Creating all AWS infrastructure (this takes 15-20 minutes)..."
terraform apply -auto-approve

# Verify cluster
echo "✅ Verifying cluster..."
aws eks describe-cluster --region us-east-1 --name mern-cluster

# Update kubeconfig
echo "🔧 Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name mern-cluster

# Check nodes
echo "📊 Checking cluster status..."
kubectl get nodes

echo "🎉 EKS cluster created successfully!"
echo "📝 Next steps:"
echo "1. Add GitHub secrets"
echo "2. Push to main branch for automatic deployment"