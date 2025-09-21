# Deployment Order

## 🎯 First Time Setup (Manual)

### 1. Create Infrastructure with Terraform
```bash
# Configure AWS CLI first
aws configure

# Create everything with Terraform
terraform init
terraform apply
```

This creates:
- ✅ VPC, Subnets, Security Groups
- ✅ EKS Cluster
- ✅ EKS Node Group
- ✅ IAM Roles
- ✅ All AWS infrastructure

### 2. Add GitHub Secrets
```bash
# Add these to GitHub Repository → Settings → Secrets:
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_REGION=us-east-1
EKS_CLUSTER_NAME=mern-cluster
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
NOTIFICATION_EMAIL=alerts@unconvensionalweb.com
```

### 3. Push to GitHub
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

## 🔄 After First Setup (Automatic)

Once infrastructure exists:
- **Push to main** → GitHub Actions automatically deploys
- **No manual Terraform needed** for app updates
- **CI/CD handles everything**

## 📋 Summary

**First Time:**
1. Terraform creates infrastructure (manual)
2. Add GitHub secrets (manual)
3. Push code (triggers CI/CD)

**Every Time After:**
1. Push code → Auto deployment via CI/CD
2. No Terraform needed for app changes

**When to Use Terraform Again:**
- Infrastructure changes (scaling, new resources)
- Cluster updates
- Security group changes