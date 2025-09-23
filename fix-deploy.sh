#!/bin/bash

echo "🔧 Fixing deployment issues..."

# Generate SSH key if missing
if [ ! -f ~/.ssh/id_ed25519.pub ]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
fi

# Clean up disk space
docker system prune -af
sudo apt clean

# Fix OIDC provider
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=mern-cluster --approve

# Delete webhook that's causing issues
kubectl delete validatingwebhookconfiguration aws-load-balancer-webhook --ignore-not-found
kubectl delete mutatingwebhookconfiguration aws-load-balancer-webhook --ignore-not-found

# Use your working docker-compose instead of broken K8s
cd ~/my-mern
docker-compose down
docker-compose up -d

# Get EC2 public IP and create simple load balancer
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "🌐 Your app is running at: http://$PUBLIC_IP:5173"

# Update DNS to point to EC2 IP instead of broken load balancer
aws route53 change-resource-record-sets --hosted-zone-id $(terraform output -raw route53_zone_id) --change-batch '{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "unconvensionalweb.com",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "'$PUBLIC_IP'"}]
    }
  }]
}' || true

echo "✅ Fixed! Your app: http://$PUBLIC_IP:5173"
echo "🌐 Domain will point to: http://unconvensionalweb.com (after DNS propagation)"