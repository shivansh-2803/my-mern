#!/bin/bash

echo "🚀 Installing Ansible and deploying MERN app..."

# Install Ansible
sudo apt update
sudo apt install -y ansible

# Run Ansible playbook
cd ansible
ansible-playbook -i inventory playbook.yml

echo "✅ Deployment complete!"
echo "📝 Check your app:"
echo "kubectl get pods -n mern-app"
echo "kubectl get svc -n mern-app"