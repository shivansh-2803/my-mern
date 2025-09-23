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
├── .github/          # CI/CD workflows
├── terraform-eks.tf # EKS infrastructure
└── main.tf          # AWS infrastructure
```

## 🛠 Technologies
- **Frontend**: React, Vite, TailwindCSS
- **Backend**: Node.js, Express, MongoDB
- **Infrastructure**: AWS EKS, Fargate, ALB
- **CI/CD**: GitHub Actions, Helm
- **Automation**: Terraform

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

### 2. Complete Deployment

#### One-Command Deploy
```bash
# Configure AWS CLI first
aws configure

# Deploy everything
chmod +x deploy.sh
./deploy.sh
```

#### Manual Steps (if needed)
```bash
# 1. Infrastructure
terraform apply

# 2. Domain
./setup-domain.sh

# 3. Application
./quick-deploy.sh
```

### 3. GitHub CI/CD (Optional)

#### Add Secrets and Push
```bash
# Add AWS credentials to GitHub Repository → Settings → Secrets
# Then push to trigger auto-deployment
git push origin main
```

### 4. Domain Setup

#### Update Name Servers
```bash
# After deployment, update your domain registrar:
# Point unconvensionalweb.com to AWS name servers from terraform output
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

### Get Load Balancer URL
```bash
# Get the load balancer DNS name
kubectl get svc frontend -n mern-app

# Copy the EXTERNAL-IP (load balancer DNS)
# Example: a1b2c3d4e5f6-123456789.us-east-1.elb.amazonaws.com
```

### Access via Load Balancer
```bash
# Open in browser:
http://YOUR_LOAD_BALANCER_DNS

# Example:
http://a1b2c3d4e5f6-123456789.us-east-1.elb.amazonaws.com
```

### Setup Custom Domain (GoDaddy)

#### Step 1: Get AWS Name Servers
```bash
# Get Route 53 name servers
terraform output route53_name_servers

# Copy all 4 name servers, example:
# ns-123.awsdns-12.com
# ns-456.awsdns-45.net
# ns-789.awsdns-78.org
# ns-012.awsdns-01.co.uk
```

#### Step 2: Update GoDaddy DNS
1. **Login to GoDaddy** → My Products → DNS
2. **Find your domain** → unconvensionalweb.com → Manage DNS
3. **Change Nameservers:**
   - Click "Change" next to Nameservers
   - Select "I'll use my own nameservers"
   - **Paste the 4 AWS nameservers** from terraform output
   - Click "Save"

#### Step 3: Wait and Access
```bash
# Wait 5-10 minutes for DNS propagation
# Then access your domain:
https://unconvensionalweb.com
https://api.unconvensionalweb.com
```

### Alternative: Direct IP Access
```bash
# If using EC2 instance instead of EKS:
http://YOUR_EC2_PUBLIC_IP:5173

# Get EC2 IP:
terraform output instance_public_ip
```

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