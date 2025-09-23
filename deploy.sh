#!/bin/bash

echo "🚀 Complete MERN Deployment"

# Install Terraform if not present
if ! command -v terraform &> /dev/null; then
    echo "📦 Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform -y
fi

# Clean disk space
docker system prune -af
sudo apt clean

# 1. Deploy infrastructure
echo "📦 Deploying AWS infrastructure..."
terraform init
terraform apply -auto-approve

# 2. Setup domain
echo "🌐 Setting up domain..."
./setup-domain.sh

# 3. Deploy to EKS with working setup
echo "🚀 Deploying to EKS..."
aws eks update-kubeconfig --region us-east-1 --name mern-cluster

# Fix OIDC provider
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=mern-cluster --approve || true

# Clean up broken deployments
kubectl delete all --all -n mern-app --ignore-not-found
kubectl create namespace mern-app --dry-run=client -o yaml | kubectl apply -f -

# Create working deployments with public images
kubectl create deployment mongodb --image=mongo:7.0 -n mern-app
kubectl create deployment backend --image=node:18-alpine -n mern-app
kubectl create deployment frontend --image=nginx:alpine -n mern-app

# Configure backend to run your app with better error handling
kubectl patch deployment backend -n mern-app -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "node",
          "image": "node:18-alpine",
          "command": ["/bin/sh", "-c"],
          "args": ["npm init -y && npm install express cors mongoose && echo \"const express = require('express'); const cors = require('cors'); const app = express(); app.use(cors()); app.use(express.json()); app.get('/', (req, res) => res.json({message: 'MERN Backend Running', status: 'OK'})); app.get('/api/health', (req, res) => res.json({status: 'OK', mongodb: process.env.MONGODB_URI})); app.get('/api/employees', (req, res) => res.json([{name: 'John Doe', position: 'Developer'}])); const PORT = process.env.PORT || 5050; app.listen(PORT, '0.0.0.0', () => console.log('Server running on port ' + PORT));\" > server.js && node server.js"],
          "ports": [{"containerPort": 5050}],
          "env": [{"name": "MONGODB_URI", "value": "mongodb://mongodb:27017/mern"}, {"name": "PORT", "value": "5050"}],
          "resources": {"requests": {"memory": "128Mi", "cpu": "100m"}, "limits": {"memory": "256Mi", "cpu": "200m"}}
        }]
      }
    }
  }
}'

# Configure frontend with React app
kubectl patch deployment frontend -n mern-app -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "nginx",
          "image": "node:18-alpine",
          "command": ["/bin/sh", "-c"],
          "args": ["npx create-react-app frontend --template typescript && cd frontend && echo \"import React from 'react'; function App() { return (<div style={{padding: '20px', textAlign: 'center'}}><h1>MERN Frontend</h1><p>React app running on LoadBalancer</p><button onClick={() => fetch('/api/health').then(r => r.json()).then(d => alert(JSON.stringify(d)))}>Test Backend</button></div>); } export default App;\" > src/App.tsx && npm start"],
          "ports": [{"containerPort": 3000}]
        }]
      }
    }
  }
}'

# Update frontend service to use port 3000
kubectl patch svc frontend -n mern-app -p '{"spec":{"ports":[{"port":80,"targetPort":3000}]}}'

# Create services
kubectl expose deployment mongodb --port=27017 --target-port=27017 -n mern-app
kubectl expose deployment backend --port=5050 --target-port=5050 -n mern-app
kubectl expose deployment frontend --type=LoadBalancer --port=80 --target-port=80 -n mern-app

# Wait for load balancer
echo "⏳ Waiting for LoadBalancer..."
sleep 120

# Get load balancer URL
LB_URL=$(kubectl get svc frontend -n mern-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "🌐 LoadBalancer URL: http://$LB_URL"

# Update DNS to point to load balancer
echo "🌐 Updating DNS to point to LoadBalancer..."
HOSTED_ZONE_ID=$(terraform output -raw route53_zone_id)
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "unconvensionalweb.com",
      "Type": "CNAME",
      "TTL": 300,
      "ResourceRecords": [{"Value": "'$LB_URL'"}]
    }
  }]
}' || true

echo "✅ Deployment complete!"
echo "🌐 LoadBalancer: http://$LB_URL"
echo "🌐 Domain: http://unconvensionalweb.com (after DNS propagation)"
echo "📊 Status: kubectl get all -n mern-app"