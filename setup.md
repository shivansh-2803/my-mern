# AWS Free Tier Setup

## Prerequisites
1. AWS account with free tier eligibility
2. AWS CLI configured with credentials
3. Terraform installed
4. SSH key pair generated

## Generate SSH Key (if not exists)
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
```

## Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

## Free Tier Resources Included
- **EC2 t2.micro**: 750 hours/month
- **VPC**: Free
- **S3**: 5GB storage, 20,000 GET requests
- **Data Transfer**: 1GB/month outbound

## MongoDB Setup
MongoDB runs as a Docker container on the same EC2 instance (completely free).

## Connect to EC2
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<instance_public_ip>
```

## Application Auto-Deployment
The application will automatically start after EC2 launch.

## Manual Deployment (if needed)
```bash
sudo docker-compose up -d
```

## Access Application
- Frontend: http://<instance_public_ip>:5173
- Backend API: http://<instance_public_ip>:5050