# Fix AWS Permissions

## 🚨 Issue: IAM User Missing Permissions

Your `mern-user` needs additional AWS policies.

## ✅ Quick Fix

### Go to AWS Console → IAM → Users → mern-user → Permissions

**Add these policies:**

1. **AmazonVPCFullAccess** - For VPC creation
2. **AmazonEC2FullAccess** - For EC2 and key pairs  
3. **AmazonS3FullAccess** - For S3 buckets
4. **IAMFullAccess** - For creating IAM roles
5. **AmazonEKSClusterPolicy** - For EKS clusters
6. **AmazonEKSServicePolicy** - For EKS service
7. **AmazonEKSWorkerNodePolicy** - For EKS nodes
8. **AmazonRoute53FullAccess** - For DNS

## 🔧 Alternative: Use Administrator Access

**Easiest option:**
- Remove all current policies
- Add: **AdministratorAccess**

⚠️ **Note**: This gives full AWS access - use carefully

## 📋 Step by Step

1. AWS Console → IAM → Users
2. Click `mern-user`
3. Click `Permissions` tab
4. Click `Add permissions` → `Attach policies directly`
5. Search and select:
   - AmazonVPCFullAccess
   - AmazonEC2FullAccess
   - AmazonS3FullAccess
   - IAMFullAccess
6. Click `Add permissions`

## 🚀 After Fixing

```bash
# Try Terraform again
terraform apply
```