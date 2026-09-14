#available version of Terraform

terraform {
  required_version = ">= 1.16.0"

  #official AWS provider by HashiCorp

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}