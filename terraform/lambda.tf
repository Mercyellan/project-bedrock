#------------------------------------------------------------------------------
# Lambda Function - Asset Processor
#------------------------------------------------------------------------------
resource "aws_lambda_function" "asset_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "bedrock-asset-processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 30

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.assets.id
    }
  }

  tags = {
    Name = "bedrock-asset-processor"
  }
}

#------------------------------------------------------------------------------
# Lambda Code Archive
#------------------------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

#------------------------------------------------------------------------------
# Lambda IAM Role
#------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-asset-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "bedrock-asset-processor-role"
  }
}

#------------------------------------------------------------------------------
# Lambda IAM Policy
#------------------------------------------------------------------------------
resource "aws_iam_role_policy" "lambda_policy" {
  name = "bedrock-asset-processor-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Lambda Permission for S3 to invoke
#------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

#------------------------------------------------------------------------------
# CloudWatch Log Group for Lambda
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/bedrock-asset-processor"
  retention_in_days = 14

  tags = {
    Name = "bedrock-asset-processor-logs"
  }
}