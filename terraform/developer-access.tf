#------------------------------------------------------------------------------
# EKS Access Entry for Terraform Executor (current IAM identity)
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# Get the current IAM session context to determine if we're using a role or user
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

resource "aws_eks_access_entry" "terraform_executor" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_session_context.current.issuer_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_executor_admin" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_session_context.current.issuer_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.terraform_executor]
}

#------------------------------------------------------------------------------
# Developer IAM User - bedrock-dev-view
#------------------------------------------------------------------------------
resource "aws_iam_user" "developer" {
  name = "bedrock-dev-view"
  path = "/"

  tags = {
    Name = "bedrock-dev-view"
  }
}

#------------------------------------------------------------------------------
# AWS Console Access - ReadOnlyAccess
#------------------------------------------------------------------------------
resource "aws_iam_user_policy_attachment" "developer_readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#------------------------------------------------------------------------------
# S3 PutObject Permission for Assets Bucket
#------------------------------------------------------------------------------
resource "aws_iam_user_policy" "developer_s3_put" {
  name = "bedrock-dev-s3-put-policy"
  user = aws_iam_user.developer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.assets.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.assets.arn
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Access Keys for Developer User
#------------------------------------------------------------------------------
resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

#------------------------------------------------------------------------------
# EKS Access Entry for Developer User (K8s RBAC)
#------------------------------------------------------------------------------
resource "aws_eks_access_entry" "developer" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_user.developer.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "developer_view" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_user.developer.arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.developer]
}