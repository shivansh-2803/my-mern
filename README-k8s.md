# Kubernetes Deployment Guide

## Prerequisites
- Kubernetes cluster (EKS, GKE, or AKS)
- kubectl configured
- Helm 3.x installed
- Domain name with DNS access

## Quick Setup

1. **Update Configuration**
   ```bash
   # Update domain in k8s/ingress.yaml
   # Update domain in helm/mern-chart/values.yaml
   # Update email in k8s/cert-manager.yaml
   ```

2. **Deploy**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **Update DNS**
   - Point `yourdomain.com` to load balancer IP
   - Point `api.yourdomain.com` to load balancer IP

## GitHub Actions Setup

1. **Add Secrets**
   - `KUBE_CONFIG`: Base64 encoded kubeconfig file

2. **Push to main branch** - Auto deployment triggers

## Architecture

```
Internet → Load Balancer → Ingress → Services → Pods
                                   ↓
                              SSL Termination
                              Domain Routing
```

## Services
- **Frontend**: `yourdomain.com` (Port 80/443)
- **Backend API**: `api.yourdomain.com` (Port 80/443)
- **MongoDB**: Internal cluster communication only

## Scaling
```bash
kubectl scale deployment frontend --replicas=5 -n mern-app
kubectl scale deployment backend --replicas=3 -n mern-app
```