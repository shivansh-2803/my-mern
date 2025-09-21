# Fix GitHub AWS Credentials

## 🚨 Error: Invalid Security Token

Your AWS credentials in GitHub secrets are invalid.

## ✅ Quick Fix

### 1. Generate New AWS Access Keys
```bash
# AWS Console → IAM → Users → mern-user → Security credentials
# Delete old access keys
# Create new access key → Command Line Interface (CLI)
# Copy: Access Key ID and Secret Access Key
```

### 2. Update GitHub Secrets
```bash
# GitHub Repository → Settings → Secrets and variables → Actions
# Update these secrets with NEW values:
```

| Secret Name | New Value |
|-------------|-----------|
| `AWS_ACCESS_KEY_ID` | Your NEW access key |
| `AWS_SECRET_ACCESS_KEY` | Your NEW secret key |

### 3. Test Locally First
```bash
# Test credentials work locally
aws configure
# Enter your new credentials

# Test access
aws sts get-caller-identity
```

### 4. Retry GitHub Actions
```bash
# Push to trigger workflow again
git commit --allow-empty -m "Test new credentials"
git push origin main
```

## 🔍 Common Causes

- **Expired keys** - AWS access keys rotated
- **Wrong region** - Check AWS_REGION secret
- **Insufficient permissions** - User needs AdministratorAccess
- **Typos** - Copy-paste errors in secrets

## ⚡ Quick Test

```bash
# Verify your current AWS setup
aws sts get-caller-identity
aws eks describe-cluster --name mern-cluster --region us-east-1
```