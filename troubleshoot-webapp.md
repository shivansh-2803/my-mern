# Webapp Not Working - Troubleshooting

## 🚨 Issue: App Not Opening on Instance IP

**Problem:** You're trying to access EKS app through EC2 instance IP - this won't work.

## 🔍 Check What's Actually Running

### Option 1: EKS Deployment
```bash
# Check if EKS cluster exists
aws eks describe-cluster --name mern-cluster --region us-east-1

# Check if pods are running
kubectl get pods -n mern-app

# Check services
kubectl get svc -n mern-app

# Check ingress (load balancer)
kubectl get ingress -n mern-app
```

### Option 2: EC2 Docker Deployment
```bash
# SSH to your EC2 instance
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Check if Docker containers are running
docker ps

# If not running, start them
docker-compose up -d

# Check logs
docker-compose logs
```

## ✅ Solutions

### If Using EKS:
```bash
# Get load balancer URL
kubectl get ingress -n mern-app
# Access via: http://LOAD_BALANCER_URL

# Or port-forward for testing
kubectl port-forward svc/frontend 8080:80 -n mern-app
# Access via: http://localhost:8080
```

### If Using EC2 Docker:
```bash
# Check security group allows port 5173
# Access via: http://YOUR_EC2_IP:5173
```

## 🎯 Quick Diagnosis

**Run this to see what's actually deployed:**
```bash
# Check EKS
kubectl get all -n mern-app

# Check EC2 Docker
ssh ubuntu@YOUR_EC2_IP "docker ps"
```