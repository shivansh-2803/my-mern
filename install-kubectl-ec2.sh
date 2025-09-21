#!/bin/bash

echo "📦 Installing kubectl on EC2..."

# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
    echo "📦 Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Configure kubectl for EKS
echo "🔧 Configuring kubectl for EKS..."
aws eks update-kubeconfig --region us-east-1 --name mern-cluster

# Test connection
echo "✅ Testing connection..."
kubectl get nodes

echo "🎉 kubectl installed and configured!"
echo "📝 You can now run: kubectl get pods -n mern-app"