#!/bin/bash

# Deploy MERN app to Kubernetes

echo "Deploying MERN application..."

# Apply namespace
kubectl apply -f k8s/namespace.yaml

# Install cert-manager (if not already installed)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s

# Apply cert-manager issuer
kubectl apply -f k8s/cert-manager.yaml

# Deploy using Helm
helm upgrade --install mern-app ./helm/mern-chart \
  --namespace mern-app \
  --create-namespace \
  --set ingress.hosts[0].host=unconvensionalweb.com \
  --set ingress.hosts[1].host=api.unconvensionalweb.com \
  --set ingress.tls[0].hosts[0]=unconvensionalweb.com \
  --set ingress.tls[0].hosts[1]=api.unconvensionalweb.com

echo "Deployment complete!"
echo "Update your DNS to point to the load balancer IP:"
kubectl get ingress -n mern-app