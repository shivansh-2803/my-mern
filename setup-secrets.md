# GitHub Secrets Setup

Add these secrets to your GitHub repository:

## AWS Configuration
```
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_REGION=us-east-1
EKS_CLUSTER_NAME=mern-cluster
```

## Email Notifications
```
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
NOTIFICATION_EMAIL=notifications@yourdomain.com
```

## Setup Steps

1. **AWS IAM User**
   - Create IAM user with EKS permissions
   - Generate access keys

2. **Gmail App Password**
   - Enable 2FA on Gmail
   - Generate app-specific password
   - Use this as EMAIL_PASSWORD

3. **Add to GitHub**
   ```bash
   # Go to: Repository → Settings → Secrets and variables → Actions
   # Add each secret above
   ```

## EKS Deployment
```bash
# Deploy EKS cluster
terraform apply -target=aws_eks_cluster.mern_cluster

# Get cluster name for GitHub secret
terraform output eks_cluster_name
```