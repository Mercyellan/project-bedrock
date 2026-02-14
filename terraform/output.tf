output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

#------------------------------------------------------------------------------
# Retail Store Frontend URL
#------------------------------------------------------------------------------
output "retail_store_url" {
  description = "URL of the Retail Store frontend"
  value       = "http://${data.kubernetes_service.ui.status[0].load_balancer[0].ingress[0].hostname}"
}

#------------------------------------------------------------------------------
# Developer User Credentials (for grading)
#------------------------------------------------------------------------------
output "developer_access_key_id" {
  description = "Access Key ID for bedrock-dev-view user"
  value       = aws_iam_access_key.developer.id
}

output "developer_secret_access_key" {
  description = "Secret Access Key for bedrock-dev-view user"
  value       = aws_iam_access_key.developer.secret
  sensitive   = true
}

#------------------------------------------------------------------------------
# EKS Cluster Information
#------------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

#------------------------------------------------------------------------------
# S3 Bucket Information
#------------------------------------------------------------------------------
output "assets_bucket_name" {
  description = "Name of the S3 assets bucket"
  value       = aws_s3_bucket.assets.id
}

#------------------------------------------------------------------------------
# Lambda Function Information
#------------------------------------------------------------------------------
output "lambda_function_name" {
  description = "Name of the asset processor Lambda function"
  value       = aws_lambda_function.asset_processor.function_name
}