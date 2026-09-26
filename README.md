# projext-cloud-infra

Terraform-based infrastructure project for the fictional `projext` environment.

The project uses the AWS provider with a local Floci runtime so infrastructure can be developed and tested without creating real AWS resources. The Terraform code is intentionally kept close to what would be used against real AWS.

## Current Architecture

![Local Development Architecture](docs/images/local-development-architecture.svg)

The Floci runtime is started separately from this repository. This repository does not start or own the Floci Docker stack.

Local endpoints:

- Floci UI: `http://localhost:4500`
- Floci API: `http://localhost:4501`
- Floci AWS-compatible backend: `http://localhost:4566`

## What Is Managed Today

The root Terraform configuration uses workspaces for environment separation.

Current environments:

```text
dev
qa
```

Application buckets:

```text
projext-dev-application-data
projext-qa-application-data
```

Terraform resource address in each workspace:

```text
aws_s3_bucket.application_data
```

The bucket name is built from the active workspace:

```text
projext + workspace + application-data
```

Common tags:

```text
Project     = projext
Environment = <active workspace>
ManagedBy   = terraform
```

## Remote State

Terraform state for the root configuration is stored remotely in a dedicated S3-compatible bucket:

```text
projext-terraform-state
```

The backend uses workspace-specific state paths:

```text
env/dev/terraform.tfstate
env/qa/terraform.tfstate
```

The default workspace also has its own base state object:

```text
terraform.tfstate
```

For local development, this backend is hosted by Floci at `http://localhost:4566`.

## Bootstrap Configuration

The remote-state bucket must exist before the root configuration can use it as a backend.

The `bootstrap/` directory is a separate Terraform configuration whose job is to create:

```text
projext-terraform-state
```

Bootstrap state remains separate from the root configuration.

Conceptually:

```text
bootstrap Terraform
        ↓
creates projext-terraform-state
        ↓
root Terraform backend
        ↓
stores dev / qa workspace state
```

## Repository Structure

```text
projext-cloud-infra/
├── bootstrap/
│   ├── .terraform.lock.hcl
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── versions.tf
├── docs/
│   └── images/
│       └── local-development-architecture.svg
├── .gitignore
├── .terraform.lock.hcl
├── backend.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
└── versions.tf
```

Local environment value files such as `dev.tfvars` and `qa.tfvars` are intentionally ignored by Git.

## Root Terraform Files

### `versions.tf`

Defines the Terraform and AWS provider requirements.

Current constraints:

- Terraform `>= 1.16.0`
- HashiCorp AWS provider `~> 6.0`

### `provider.tf`

Configures the AWS provider for local Floci development.

It:

- uses region `us-east-1`
- uses local test credentials
- skips AWS validation calls that are not required by the emulator
- redirects S3 requests to `http://localhost:4566`

In a real AWS deployment, credentials would normally come from AWS CLI/SSO, environment variables, IAM roles, or CI/CD OIDC. The Floci endpoint override and emulator-specific skip settings would normally be removed.

### `backend.tf`

Configures the root Terraform state backend.

It stores state in:

```text
projext-terraform-state
```

and uses:

```text
workspace_key_prefix = "env"
```

so non-default workspaces are stored separately.

### `variables.tf`

Declares required Terraform inputs.

Current variable:

```text
project
```

The environment is no longer supplied as a variable. It is derived from the active Terraform workspace.

### `locals.tf`

Defines reusable calculated values.

Current pattern:

```text
terraform.workspace
        ↓
local.environment
        ↓
local.name_prefix
        ↓
projext-dev / projext-qa
```

It also defines reusable common tags.

### `main.tf`

Defines the application-data S3 bucket:

```text
${local.name_prefix}-application-data
```

Examples:

```text
dev → projext-dev-application-data
qa  → projext-qa-application-data
```

### `outputs.tf`

Exposes:

- application data bucket name
- application data bucket ARN

Because outputs are stored per workspace, the same output name returns the value for the active workspace.

## Workspace Workflow

Check the active workspace before planning or applying:

```bash
terraform workspace show
```

Development:

```bash
terraform workspace select dev
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

QA:

```bash
terraform workspace select qa
terraform plan -var-file=qa.tfvars
terraform apply -var-file=qa.tfvars
```

The workspace controls which state Terraform uses. The `.tfvars` file supplies environment-specific input values that are still needed by the configuration.

## Terraform Workflow

Typical local workflow:

```text
terraform fmt
        ↓
terraform validate
        ↓
terraform workspace show
        ↓
terraform plan -var-file=<environment>.tfvars
        ↓
review
        ↓
terraform apply -var-file=<environment>.tfvars
```

When a working directory is new, or providers/modules/backend configuration change:

```bash
terraform init
```

The root configuration was migrated from local state to the S3 backend with:

```bash
terraform init -migrate-state
```

## Verifying Remote State

With the local Floci credentials exported:

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

List the backend objects:

```bash
aws s3 ls s3://projext-terraform-state --recursive --endpoint-url http://localhost:4566
```

Expected workspace state objects include:

```text
env/dev/terraform.tfstate
env/qa/terraform.tfstate
```

## Floci vs Real AWS

Local development:

```text
Terraform
→ AWS provider / S3 backend
→ localhost:4566
→ Floci
```

Real AWS:

```text
Terraform
→ AWS provider / S3 backend
→ AWS APIs
```

The resource definitions remain largely the same. The main differences are authentication and endpoint configuration.

## Current Milestones

The project now covers:

- Terraform initialization, formatting, validation, planning, and apply
- AWS provider dependency locking
- local AWS emulation with Floci
- persistent Floci runtime
- S3 resource creation
- input variables
- locals and reusable common tags
- Terraform outputs
- Terraform workspaces
- separate dev and QA infrastructure
- workspace-based environment naming
- bootstrap Terraform configuration
- dedicated Terraform state bucket
- S3 remote backend
- migration from local state to remote state
- remote workspace state verification
- Git/GitHub workflow for infrastructure changes

## Next Step

The next phase is CI/CD with GitHub Actions: initialize Terraform on a fresh runner, connect to the remote backend, select the correct workspace, validate, plan, and eventually apply with appropriate approval controls.
