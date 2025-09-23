#!/bin/bash

echo "🚀 Complete MERN Deployment"

# 1. Deploy infrastructure
echo "📦 Deploying AWS infrastructure..."
terraform init
terraform apply -auto-approve

# 2. Setup domain
echo "🌐 Setting up domain..."
./setup-domain.sh

# 3. Deploy application
echo "🎯 Deploying application..."
./quick-deploy.sh

echo "✅ Deployment complete!"
echo "🌐 Your app: https://unconvensionalweb.com"