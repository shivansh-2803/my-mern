terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mern-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "mern-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "mern-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "mern-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "web" {
  name_prefix = "mern-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (t2.micro - free tier)
resource "aws_instance" "web" {
  ami                    = "ami-0866a3c8686eaeeba" # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.public.id

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io git snapd
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ubuntu
              curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Install AWS CLI and kubectl
              snap install aws-cli --classic
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/
              
              # Clone and start the application
              cd /home/ubuntu
              git clone https://github.com/shivansh-2803/my-mern.git
              mkdir -p /home/ubuntu/my-mern/db_data
              chown -R ubuntu:ubuntu /home/ubuntu/my-mern
              cd my-mern
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              echo 'MONGODB_URI=mongodb://mongodb:27017' > .env
              echo "FRONTEND_URL=http://$PUBLIC_IP:5173" >> .env
              echo "CORS_ORIGIN=http://$PUBLIC_IP:5173" >> .env
              echo "VITE_API_URL=http://$PUBLIC_IP:5050" > mern/frontend/.env.production
              sudo -u ubuntu docker-compose up -d
              EOF

  tags = {
    Name = "mern-server"
  }
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "mern-key"
  public_key = file("~/.ssh/id_ed25519.pub") # You need to generate this
}



# S3 Bucket (free tier includes 5GB)
resource "aws_s3_bucket" "static" {
  bucket = "mern-static-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_public_access_block" "static" {
  bucket = aws_s3_bucket.static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.static.id

  index_document {
    suffix = "index.html"
  }
}

# Outputs
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}



output "s3_bucket_name" {
  value = aws_s3_bucket.static.bucket
}

output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.static.website_endpoint
}