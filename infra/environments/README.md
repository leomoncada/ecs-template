# Per-environment Terraform roots

Each environment has its **own directory**, **own state** (S3 key), and **own tfvars** so staging and prod never mix.

- **`staging/`** — Apply from here for staging. Backend key: `portfolio/staging/terraform.tfstate`.
- **`prod/`** — Apply from here for prod. Backend key: `portfolio/prod/terraform.tfstate`.

## Apply

1. Edit `main.tf` in the environment folder and set the real S3 `bucket` (and optional `dynamodb_table` if you add locking).
2. Copy and edit tfvars:
   ```bash
   cd staging   # or prod
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars (backend_image, frontend_image, etc.)
   ```
3. Init and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

Each folder uses the shared module `../../modules/portfolio` (VPC, ALB, ECS). Only variables and state differ per environment.
