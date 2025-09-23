#!/bin/bash

echo "🚀 Complete MERN Deployment"

# Install Terraform if not present
if ! command -v terraform &> /dev/null; then
    echo "📦 Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform -y
fi

# Install eksctl and helm
if ! command -v eksctl &> /dev/null; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
fi

if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# 1. Deploy infrastructure
echo "📦 Deploying AWS infrastructure..."
terraform init
terraform apply -auto-approve

# 2. Setup domain
echo "🌐 Setting up domain..."
./setup-domain.sh

# 3. Build Docker images locally
echo "📦 Building Docker images..."
docker build -t mern-frontend:latest ./mern/frontend
docker build -t mern-backend:latest ./mern/backend

# 4. Deploy to EKS
echo "🎯 Deploying to EKS..."
aws eks update-kubeconfig --region us-east-1 --name mern-cluster

# Fix AWS Load Balancer Controller
echo "🔧 Installing Load Balancer Controller..."
kubectl delete deployment aws-load-balancer-controller -n kube-system --ignore-not-found
kubectl delete validatingwebhookconfiguration aws-load-balancer-webhook --ignore-not-found
kubectl delete mutatingwebhookconfiguration aws-load-balancer-webhook --ignore-not-found

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
sleep 30

# Create IAM policy and service account
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json --region us-east-1 || true

eksctl create iamserviceaccount --cluster=mern-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-east-1 || true

# Install controller via Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=mern-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller || true

sleep 60

# 5. Deploy application
echo "🚀 Deploying MERN app..."
kubectl delete all --all -n mern-app --ignore-not-found
kubectl create namespace mern-app --dry-run=client -o yaml | kubectl apply -f -

# Load images to EKS nodes
docker save mern-frontend:latest | kubectl run temp-pod --rm -i --restart=Never --image=docker:dind -- docker load
docker save mern-backend:latest | kubectl run temp-pod --rm -i --restart=Never --image=docker:dind -- docker load

# Create deployments
kubectl create deployment mongodb --image=mongo:7.0 -n mern-app
kubectl create deployment backend --image=mern-backend:latest -n mern-app
kubectl create deployment frontend --image=mern-frontend:latest -n mern-app

# Set environment variables
kubectl set env deployment/backend MONGODB_URI=mongodb://mongodb:27017 PORT=5050 -n mern-app

# Create services
kubectl expose deployment mongodb --port=27017 --target-port=27017 -n mern-app
kubectl expose deployment backend --port=5050 --target-port=5050 -n mern-app
kubectl expose deployment frontend --type=LoadBalancer --port=80 --target-port=5173 -n mern-app

# Wait for load balancer
echo "⏳ Waiting for LoadBalancer..."
sleep 120

# 6. Update DNS records
echo "🌐 Updating DNS records..."
./update-dns.sh

echo "✅ Deployment complete!"
echo "🌐 Your app: https://unconvensionalweb.com"
echo "📊 Status: kubectl get all -n mern-app"