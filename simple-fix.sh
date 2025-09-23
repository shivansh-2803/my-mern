#!/bin/bash

echo "🔧 Simple fix - using working docker-compose"

# Stop broken K8s deployment
kubectl delete all --all -n mern-app --ignore-not-found

# Use your working docker-compose setup
cd ~/my-mern
docker-compose down
docker-compose up -d

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create simple nginx proxy to expose on port 80
sudo tee /etc/nginx/sites-available/mern > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:5173;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/mern /etc/nginx/sites-enabled/
sudo systemctl reload nginx

echo "✅ App running at: http://$PUBLIC_IP"
echo "🌐 Access via: http://unconvensionalweb.com (after DNS update)"