#!/bin/bash

echo "🔧 Fixing Fargate compatibility..."

# Delete stuck pods
kubectl delete pods --all -n mern-app

# Delete deployments
kubectl delete deployment --all -n mern-app

# Redeploy with Fargate-compatible manifests
kubectl apply -f k8s/

echo "✅ Redeployed without persistent volumes"
echo "📊 Check status: kubectl get pods -n mern-app"