# Load Balancer Setup for Domain

## 🎯 Problem
EKS with Fargate needs AWS Load Balancer Controller to create load balancers for your domain.

## ✅ Solution Steps

### 1. Deploy EKS Cluster First
```bash
terraform apply
```

### 2. Install AWS Load Balancer Controller
```bash
# Install eksctl first
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Run setup script
chmod +x setup-load-balancer.sh
./setup-load-balancer.sh
```

### 3. Request SSL Certificate
```bash
# AWS Console → Certificate Manager → Request certificate
# Domain: unconvensionalweb.com
# Validation: DNS validation
# Copy certificate ARN
```

### 4. Update Ingress with Certificate
```bash
# Edit k8s/ingress.yaml
# Replace ACCOUNT_ID and CERTIFICATE_ID with your values
```

### 5. Deploy Application
```bash
kubectl apply -f k8s/
```

### 6. Get Load Balancer DNS
```bash
kubectl get ingress -n mern-app
# Copy the ADDRESS field
```

### 7. Update DNS Records
```bash
# Point your domain to the load balancer:
# CNAME: unconvensionalweb.com → k8s-mernapp-merninge-xxxxxxxxxx-xxxxxxxxxx.us-east-1.elb.amazonaws.com
# CNAME: api.unconvensionalweb.com → k8s-mernapp-merninge-xxxxxxxxxx-xxxxxxxxxx.us-east-1.elb.amazonaws.com
```

## 🚀 Quick Commands

```bash
# 1. Deploy infrastructure
terraform apply

# 2. Setup load balancer
./setup-load-balancer.sh

# 3. Request SSL cert in AWS Console

# 4. Deploy app
kubectl apply -f k8s/

# 5. Get load balancer DNS
kubectl get ingress -n mern-app
```

## 💰 Cost
- Application Load Balancer: ~$16/month
- Total with Fargate: ~$99-109/month