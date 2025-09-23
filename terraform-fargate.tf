# Faster alternative: EKS with Fargate (serverless)
resource "aws_eks_fargate_profile" "mern_fargate" {
  cluster_name           = aws_eks_cluster.mern_cluster.name
  fargate_profile_name   = "mern-fargate"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn

  subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]

  selector {
    namespace = "mern-app"
  }
}

resource "aws_iam_role" "fargate_pod_execution" {
  name = "eks-fargate-pod-execution-role-mern"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution.name
}