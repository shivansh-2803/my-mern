# MERN Stack Application

Complete production-ready MERN application with AWS EKS deployment, CI/CD, and domain hosting.

## 🚀 Quick Start

### Local Development
```bash
docker-compose up -d
```
Access: http://localhost:5173

### Production Deployment
```bash
# 1. Deploy infrastructure
terraform apply

# 2. Deploy application
./quick-deploy.sh

# 3. Get your website URL
kubectl get svc frontend -n mern-app
```

## 📁 Project Structure
```
├── mern/
│   ├── frontend/     # React app (Vite + TailwindCSS)
│   └── backend/      # Express API + MongoDB
├── k8s/              # Kubernetes manifests
├── helm/             # Helm charts
├── ansible/          # Automation playbooks
├── .github/          # CI/CD workflows
├── terraform-eks.tf # EKS infrastructure
└── main.tf          # AWS infrastructure
```

## 🛠 Technologies
- **Frontend**: React, Vite, TailwindCSS
- **Backend**: Node.js, Express, MongoDB
- **Infrastructure**: AWS EKS, Fargate, ALB
- **CI/CD**: GitHub Actions, Helm
- **Automation**: Ansible, Terraform

## 📋 Complete Setup Guide

### 1. AWS Setup

#### Create IAM User
```bash
# AWS Console → IAM → Users → Create User
# User name: mern-user
# Attach policy: AdministratorAccess (or specific policies below)
```

**Required Policies:**
- AmazonVPCFullAccess
- AmazonEC2FullAccess
- AmazonS3FullAccess
- IAMFullAccess
- AmazonEKSClusterPolicy
- AmazonRoute53FullAccess

#### Generate Access Keys
```bash
# IAM → Users → mern-user → Security credentials
# Create access key → Command Line Interface (CLI)
# Save: Access Key ID and Secret Access Key
```

### 2. Deploy Infrastructure

#### Configure AWS CLI
```bash
aws configure
# Enter your Access Key ID and Secret Access Key
# Region: us-east-1
```

#### Deploy with Terraform
```bash
# Initialize and deploy
terraform init
terraform apply

# Verify EKS cluster
aws eks describe-cluster --name mern-cluster --region us-east-1
```

### 3. Deploy Application

#### Option A: Quick Deploy (Recommended)
```bash
# SSH to your EC2 instance or run locally
chmod +x quick-deploy.sh
./quick-deploy.sh

# Check deployment
kubectl get pods -n mern-app
kubectl get svc -n mern-app
```

#### Option B: Ansible Automation
```bash
chmod +x deploy-with-ansible.sh
./deploy-with-ansible.sh
```

#### Option C: Manual Kubernetes
```bash
kubectl apply -f k8s/
```

### 4. GitHub CI/CD Setup

#### Add Repository Secrets
Go to: GitHub Repository → Settings → Secrets and variables → Actions

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | `wJalrXUt...` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `EKS_CLUSTER_NAME` | EKS cluster name | `mern-cluster` |
| `EMAIL_USERNAME` | Gmail address | `your-email@gmail.com` |
| `EMAIL_PASSWORD` | Gmail app password | `abcd efgh ijkl mnop` |
| `NOTIFICATION_EMAIL` | Email for notifications | `alerts@unconvensionalweb.com` |

#### Setup Gmail App Password
```bash
# 1. Enable 2-Factor Authentication on Gmail
# 2. Go to: Google Account → Security → 2-Step Verification → App passwords
# 3. Generate password for "Mail"
# 4. Use this 16-character password as EMAIL_PASSWORD
```

#### Trigger Deployment
```bash
git add .
git commit -m "Deploy to production"
git push origin main
# Check GitHub Actions tab for deployment status
```

### 5. Domain Configuration

#### Request SSL Certificate
```bash
# AWS Console → Certificate Manager → Request certificate
# Domain: unconvensionalweb.com
# Add: api.unconvensionalweb.com
# Validation: DNS validation
# Copy certificate ARN
```

#### Update DNS Records
```bash
# Get load balancer DNS
kubectl get ingress -n mern-app

# Add DNS records in your domain provider:
# CNAME: unconvensionalweb.com → k8s-mernapp-xxxxx.us-east-1.elb.amazonaws.com
# CNAME: api.unconvensionalweb.com → k8s-mernapp-xxxxx.us-east-1.elb.amazonaws.com
```

#### Configure Ingress
```bash
# Edit k8s/ingress.yaml
# Replace ACCOUNT_ID and CERTIFICATE_ID with your values
# Apply changes
kubectl apply -f k8s/ingress.yaml
```

## 🔧 Management Commands

### View Application Status
```bash
# Check pods
kubectl get pods -n mern-app

# Check services
kubectl get svc -n mern-app

# Check ingress
kubectl get ingress -n mern-app

# View logs
kubectl logs -f deployment/frontend -n mern-app
kubectl logs -f deployment/backend -n mern-app
```

### Scale Application
```bash
# Scale frontend
kubectl scale deployment frontend --replicas=3 -n mern-app

# Scale backend
kubectl scale deployment backend --replicas=2 -n mern-app
```

### Update Application
```bash
# Push to main branch triggers automatic deployment
git push origin main

# Or manual update
kubectl set image deployment/frontend frontend=ghcr.io/your-repo/mern-frontend:new-tag -n mern-app
```

## 🚨 Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl describe pod POD_NAME -n mern-app

# Check events
kubectl get events -n mern-app --sort-by='.lastTimestamp'
```

#### LoadBalancer Pending
```bash
# Check AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer

# Install if missing
./setup-load-balancer.sh
```

#### SSL Certificate Issues
```bash
# Check certificate status
kubectl describe certificate mern-tls -n mern-app

# Verify DNS validation in AWS Certificate Manager
```

#### GitHub Actions Failing
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify EKS cluster exists
aws eks describe-cluster --name mern-cluster --region us-east-1

# Update GitHub secrets if needed
```

## 📊 Monitoring & Costs

### Cost Breakdown
- **EKS Control Plane**: $73/month
- **Fargate Pods**: $10-20/month (pay per use)
- **Application Load Balancer**: $16/month
- **Total**: ~$99-109/month

### Monitoring
```bash
# Resource usage
kubectl top pods -n mern-app
kubectl top nodes

# Application metrics
kubectl get hpa -n mern-app
```

## 🔄 CI/CD Pipeline

### Workflow Triggers
- **Push to main** → Build + Deploy + Notify
- **Pull Request** → Build only

### Pipeline Steps
1. **Build** Docker images
2. **Push** to GitHub Container Registry
3. **Deploy** to EKS using Helm
4. **Send** email notifications

### Email Notifications
You'll receive emails for:
- ✅ Successful deployments
- ❌ Failed deployments
- 📊 Deployment details and links

## 🔐 Security Features

- SSL certificates auto-renewed
- Private subnets for worker nodes
- IAM roles with minimal permissions
- Container image scanning enabled
- Secrets management with Kubernetes

## 📱 Application Features

- **Employee CRUD operations**
- **Responsive UI** with TailwindCSS
- **Real-time data** with MongoDB
- **Docker containerization**
- **Kubernetes orchestration**
- **Auto-scaling capabilities**
- **Production-ready architecture**

## 🌐 Access Your Application

### URLs
- **Frontend**: https://unconvensionalweb.com
- **Backend API**: https://api.unconvensionalweb.com
- **Health Check**: https://api.unconvensionalweb.com/record

### Local Testing
```bash
# Port forward for local access
kubectl port-forward svc/frontend 8080:80 -n mern-app
# Access: http://localhost:8080
```

## 📞 Support

If you encounter issues:
1. Check application logs: `kubectl logs -f deployment/frontend -n mern-app`
2. Verify AWS resources in console
3. Check GitHub Actions logs
4. Review email notifications for deployment status

---

**🎉 Your MERN application is now production-ready with enterprise-grade infrastructure!**