#!/bin/bash

echo "🔧 Fixing Fargate timeout issues..."

# Update Fargate profile with more subnets
terraform apply -target=aws_eks_fargate_profile.mern_fargate

# Delete stuck pods and deployments
kubectl delete pods --all -n mern-app
kubectl delete deployment --all -n mern-app

# Wait a moment
sleep 10

# Redeploy with reduced resources
kubectl apply -f k8s/

echo "✅ Redeployed with optimized resources"
echo "📊 Monitor: kubectl get pods -n mern-app -w"