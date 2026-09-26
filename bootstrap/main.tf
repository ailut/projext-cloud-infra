# provisioning s3 bucket for terraform remote state.

resource "aws_s3_bucket" "terraform_state" {
  bucket = "projext-terraform-state"

  tags = {
    Project   = "projext"
    ManagedBy = "terraform"
    Purpose   = "Terraform state"
  }
}