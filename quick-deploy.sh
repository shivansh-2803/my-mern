#!/bin/bash

echo "🚀 Quick Deploy - Creating namespace and basic pods..."

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name mern-cluster

# Create namespace
kubectl create namespace mern-app --dry-run=client -o yaml | kubectl apply -f -

# Deploy MongoDB
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  namespace: mern-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:7.0
        ports:
        - containerPort: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  namespace: mern-app
spec:
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
EOF

# Deploy Frontend with LoadBalancer
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: mern-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: mern-app
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
EOF

echo "⏳ Waiting for pods to start..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n mern-app

echo "✅ Deployment complete!"
echo "📊 Status:"
kubectl get pods -n mern-app
kubectl get svc -n mern-app

echo "🌐 LoadBalancer URL:"
kubectl get svc frontend -n mern-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""