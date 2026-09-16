# Here we create an S3 bucket resource in  FLOCI env
resource "aws_s3_bucket" "application_data" {
  bucket = "${local.name_prefix}-application-data"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
