#!/bin/bash

echo "🔍 Debugging pending pods..."

# Check pod details
kubectl describe pod -n mern-app | grep -A 10 "Events:"

# Check Fargate profile
aws eks describe-fargate-profile --cluster-name mern-cluster --fargate-profile-name mern-fargate

# Check nodes
kubectl get nodes

echo "📋 Common fixes:"
echo "1. Check if Fargate profile exists and matches namespace"
echo "2. Verify subnet configuration"
echo "3. Check resource limits"
#