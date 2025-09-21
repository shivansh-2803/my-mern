# EKS Cluster for Kubernetes deployment
resource "aws_eks_cluster" "mern_cluster" {
  name     = "mern-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"

  vpc_config {
    subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "mern-private-subnet"
  }
}

# Removed slow node group - using Fargate instead

# IAM roles for EKS
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role-mern"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Node group IAM roles removed - using Fargate

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.mern_cluster.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.mern_cluster.name
}