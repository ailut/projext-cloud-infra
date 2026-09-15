# Here we create an S3 bucket resource in local FLOCI env
resource "aws_s3_bucket" "application_data" {
  bucket = "projext-dev-application-data"

  tags = {
    Project     = "projext"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}