#using aws provider
#point s3 to 'FLOCI' aws

# EDIT: projext-cloud-infra :-
# 1.does NOT start Floci anymore
# 2.only connects to it

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

# IN AN ACTUAL AWS DEPLOYMENT(INSTEAD HANDLED BY CLI):

# 1. No need of credential validation
# 2. No need of specifying endpoints for s3.
# 3. Skip settings are not needed for this setup.