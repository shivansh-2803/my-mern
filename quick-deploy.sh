#!/bin/bash

echo "🚀 Deploying MERN App to EKS..."

# Configure and deploy
aws eks update-kubeconfig --region us-east-1 --name mern-cluster
kubectl apply -f k8s/

echo "⏳ Waiting for pods to start..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n mern-app

echo "✅ Deployment complete!"
echo "📊 Status:"
kubectl get pods -n mern-app
kubectl get svc -n mern-app

echo "🌐 LoadBalancer URL:"
kubectl get svc frontend -n mern-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
#