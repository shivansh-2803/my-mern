# MERN App Deployment Guide

Complete step-by-step guide to deploy your MERN application to AWS EKS with CI/CD.

## 🚀 Quick Start

### Prerequisites
- AWS Account
- Domain name
- GitHub repository
- kubectl and Helm installed locally

## 📋 Step-by-Step Deployment

### 1. AWS Setup

#### Create IAM User
```bash
# AWS Console → IAM → Users → Create User
# User name: mern-deploy-user
# Attach policies:
# - AmazonEKSClusterPolicy
# - AmazonEKSWorkerNodePolicy
# - AmazonEC2ContainerRegistryFullAccess
# - AmazonRoute53FullAccess
```

#### Generate Access Keys
```bash
# IAM → Users → mern-deploy-user → Security credentials
# Create access key → Command Line Interface (CLI)
# Save: Access Key ID and Secret Access Key
```

### 2. Deploy Infrastructure

#### Update Configuration
```bash
# Edit terraform-eks.tf - update region if needed
# Domain already configured for unconvensionalweb.com
# Files already updated with your domain
# Edit k8s/cert-manager.yaml - replace 'your-email@domain.com' with your email
```

#### Deploy EKS Cluster
```bash
# Initialize Terraform
terraform init

# Deploy EKS cluster (takes 10-15 minutes)
terraform apply -target=aws_eks_cluster.mern_cluster
terraform apply -target=aws_eks_node_group.mern_nodes

# Get cluster info
terraform output eks_cluster_name
terraform output eks_cluster_endpoint
```

### 3. GitHub Setup

#### Add Repository Secrets
```bash
# Go to: GitHub Repository → Settings → Secrets and variables → Actions
# Add these secrets (GITHUB_TOKEN is automatically provided):
```

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | `wJalrXUt...` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `EKS_CLUSTER_NAME` | EKS cluster name | `mern-cluster` |
| `EMAIL_USERNAME` | Gmail address | `your-email@gmail.com` |
| `EMAIL_PASSWORD` | Gmail app password | `abcd efgh ijkl mnop` |
| `NOTIFICATION_EMAIL` | Email for notifications | `alerts@unconvensionalweb.com` |
| `GITHUB_TOKEN` | Auto-generated | *Automatically provided by GitHub* |

#### Setup Gmail App Password
```bash
# 1. Enable 2-Factor Authentication on Gmail
# 2. Go to: Google Account → Security → 2-Step Verification → App passwords
# 3. Generate password for "Mail"
# 4. Use this 16-character password as EMAIL_PASSWORD
```

### 4. Domain Configuration

#### Update DNS Records
```bash
# Get load balancer IP after deployment:
kubectl get ingress -n mern-app

# Add DNS records:
# A record: unconvensionalweb.com → LOAD_BALANCER_IP
# A record: api.unconvensionalweb.com → LOAD_BALANCER_IP
```

### 5. Deploy Application

#### Option A: Automatic (Recommended)
```bash
# Push to main branch - triggers automatic deployment
git add .
git commit -m "Deploy to production"
git push origin main

# Check deployment status:
# GitHub → Actions tab
```

#### Option B: Manual
```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name mern-cluster

# Deploy manually
chmod +x deploy.sh
./deploy.sh
```

### 6. Verify Deployment

#### Check Services
```bash
# Check pods
kubectl get pods -n mern-app

# Check services
kubectl get svc -n mern-app

# Check ingress
kubectl get ingress -n mern-app

# Check certificates
kubectl get certificates -n mern-app
```

#### Test Application
```bash
# Frontend: https://unconvensionalweb.com
# Backend API: https://api.unconvensionalweb.com/record
```

## 🔧 Configuration Files

### Update These Files Before Deployment:

1. **k8s/ingress.yaml** - Replace `yourdomain.com`
2. **helm/mern-chart/values.yaml** - Replace `yourdomain.com`
3. **k8s/cert-manager.yaml** - Replace `your-email@domain.com`
4. **mern/frontend/.env.production** - Update API URL

## 📊 Monitoring & Scaling

### View Logs
```bash
# Frontend logs
kubectl logs -f deployment/frontend -n mern-app

# Backend logs
kubectl logs -f deployment/backend -n mern-app

# MongoDB logs
kubectl logs -f deployment/mongodb -n mern-app
```

### Scale Application
```bash
# Scale frontend
kubectl scale deployment frontend --replicas=5 -n mern-app

# Scale backend
kubectl scale deployment backend --replicas=3 -n mern-app
```

## 🚨 Troubleshooting

### Common Issues

#### SSL Certificate Not Working
```bash
# Check cert-manager
kubectl get pods -n cert-manager

# Check certificate status
kubectl describe certificate mern-tls -n mern-app
```

#### Pods Not Starting
```bash
# Check pod status
kubectl describe pod POD_NAME -n mern-app

# Check events
kubectl get events -n mern-app --sort-by='.lastTimestamp'
```

#### Database Connection Issues
```bash
# Check MongoDB pod
kubectl logs deployment/mongodb -n mern-app

# Test connection from backend
kubectl exec -it deployment/backend -n mern-app -- ping mongodb
```

## 📧 Email Notifications

You'll receive emails for:
- ✅ Successful deployments
- ❌ Failed deployments
- 📊 Deployment details and links

## 🔄 CI/CD Pipeline

### Workflow Triggers:
- **Push to main** → Build + Deploy + Notify
- **Pull Request** → Build only

### Pipeline Steps:
1. **Build** Docker images
2. **Push** to GitHub Container Registry
3. **Deploy** to EKS using Helm
4. **Notify** via email

## 💰 Cost Optimization

### Free Tier Resources:
- EKS Control Plane: $0.10/hour
- t3.medium nodes: ~$0.04/hour each
- Load Balancer: ~$0.025/hour

### Estimated Monthly Cost: ~$50-80

## 🔐 Security

- SSL certificates auto-renewed
- Private subnets for worker nodes
- IAM roles with minimal permissions
- Container image scanning enabled

## 📞 Support

If you encounter issues:
1. Check GitHub Actions logs
2. Review kubectl logs
3. Verify DNS configuration
4. Check email notifications for details