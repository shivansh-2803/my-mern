# MERN Stack Application

Employee management system built with MongoDB, Express, React, and Node.js.

## 🚀 Quick Start

### Local Development
```bash
docker-compose up -d
```
Access: http://localhost:5173

### Production Deployment
See **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** for complete AWS EKS deployment with:
- Kubernetes orchestration
- Load balancer & SSL
- CI/CD pipeline
- Email notifications
- Auto-scaling

## 📁 Project Structure
```
├── mern/
│   ├── frontend/     # React app
│   └── backend/      # Express API
├── k8s/              # Kubernetes manifests
├── helm/             # Helm charts
├── .github/          # CI/CD workflows
└── terraform-eks.tf  # EKS infrastructure
```

## 🛠 Technologies
- **Frontend**: React, Vite, TailwindCSS
- **Backend**: Node.js, Express, MongoDB
- **Infrastructure**: AWS EKS, Terraform
- **CI/CD**: GitHub Actions, Helm
- **Monitoring**: Email notifications

## 📋 Features
- Employee CRUD operations
- Responsive UI
- Docker containerization
- Kubernetes deployment
- Auto SSL certificates
- Production-ready scaling

---
**For deployment instructions, see [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)**