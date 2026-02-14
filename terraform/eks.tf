
#------------------------------------------------------------------------------
# EKS Cluster
#------------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  version  = var.eks_version
  role_arn = aws_iam_role.eks_cluster.arn

  # Enable API authentication mode for EKS access entries
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  # Enable Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure IAM role policies are attached before creating cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "${var.project_name}-cluster"
  }

  # Prevent cluster recreation when access_config changes
  lifecycle {
    ignore_changes = [access_config]
  }
}

#------------------------------------------------------------------------------
# CloudWatch Log Group for EKS Control Plane
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.project_name}-cluster/cluster"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-cluster-logs"
  }
}

#------------------------------------------------------------------------------
# EKS Cluster Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-cluster-sg"
  }
}

#------------------------------------------------------------------------------
# EKS Node Group
#------------------------------------------------------------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id

  instance_types = var.eks_node_instance_types
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure IAM role policies are attached before creating node group
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy
  ]

  tags = {
    Name = "${var.project_name}-node-group"
  }
}

# CloudWatch Observability EKS Add-on is installed via Helm instead of Terraform
# because the t3.micro nodes are too small for the full CloudWatch agent.
# Install FluentBit for container logging using:
# helm repo add fluent https://fluent.github.io/helm-charts
# helm install fluent-bit fluent/fluent-bit --namespace amazon-cloudwatch --create-namespace \
#   --set cloudWatch.region=us-east-1 \
#   --set cloudWatch.logGroupName=/aws/eks/project-bedrock-cluster/containers

#------------------------------------------------------------------------------
# IAM Role for CloudWatch Observability
#------------------------------------------------------------------------------
resource "aws_iam_role" "cloudwatch_observability" {
  name = "${var.project_name}-cloudwatch-observability-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cloudwatch-observability-role"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_observability.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability_xray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = aws_iam_role.cloudwatch_observability.name
}

#------------------------------------------------------------------------------
# OIDC Provider for EKS (required for IRSA)
#------------------------------------------------------------------------------
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.project_name}-eks-oidc"
  }
}
