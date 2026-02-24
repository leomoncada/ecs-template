# Per-environment Terraform roots

Each environment has its **own directory**, **own state** (S3 key), and **own tfvars** so staging and prod never mix.

- **`staging/`** — Apply from here for staging. Backend key: `portfolio/staging/terraform.tfstate`.
- **`prod/`** — Apply from here for prod. Backend key: `portfolio/prod/terraform.tfstate`.

## Backend (state and lock)

The S3 backend supports an optional **DynamoDB table** for state locking (avoids concurrent apply conflicts). The bucket and table names in `main.tf` are placeholders.

1. Create an S3 bucket and a DynamoDB table (e.g. `terraform-state-lock`) with partition key `LockID` (String).
2. Copy `backend-config.example` to `backend.hcl` in the same folder (do not commit `backend.hcl` if it contains real names).
3. Set real values in `backend.hcl` for `bucket` and `dynamodb_table`.
4. Init with: `terraform init -backend-config=backend.hcl`.

If you do not use `-backend-config`, ensure `main.tf` uses your real bucket and table (e.g. via CI env or a non-committed override).

## Apply

1. Copy and edit tfvars:
   ```bash
   cd staging   # or prod
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars (backend_image, frontend_image, etc.)
   ```
2. Init (with backend-config if you use it) and apply:
   ```bash
   terraform init -backend-config=backend.hcl   # or terraform init
   terraform plan
   terraform apply
   ```

Each folder uses the shared module `../../modules/portfolio` (VPC, ALB, ECS, CloudWatch alarms). Only variables and state differ per environment.
