# Infrastructure (Terraform)

VPC 3 layers (public, app, DB), ECS Fargate, ALB. ECR repos are shared across environments and live in `global/`.

## Prerequisites

- Terraform >= 1.5
- AWS credentials (profile or env)

## Apply order

1. **Global (once per account):** Create shared ECR repos (`portfolio-backend`, `portfolio-frontend`). Staging and prod use the same repos; only the image tag differs (`staging` / `prod`).
   ```bash
   cd global
   terraform init && terraform plan && terraform apply
   ```
2. **Per environment:** Each environment has its own directory (and state). Use **`environments/staging/`** and **`environments/prod/`** so tfvars and state are clearly separated.
   ```bash
   cd environments/staging   # or prod
   cp terraform.tfvars.example terraform.tfvars
   # Edit main.tf: set the real S3 bucket for the backend. Edit terraform.tfvars: backend_image, frontend_image (tag :staging or :prod).
   terraform init
   terraform plan
   terraform apply
   ```
   See [environments/README.md](environments/README.md) for details. Each folder uses the same module `modules/portfolio`; only variables and backend state key differ.
3. Use `terraform output alb_dns_name` for the dashboard URL (http://\<dns_name\>).

**LocalStack:** Run `./scripts/validate-localstack.sh plan` from the repo root; it uses `environments/staging/` with `-backend=false` and `infra/terraform.tfvars.localstack` so there is no extra root Terraform entry point.

**CI/CD:** GitHub Actions build only on push to `staging` and promote the same image to `prod`. Configure secrets `ECR_REPOSITORY_BACKEND` and `ECR_REPOSITORY_FRONTEND` with the repository **names** (e.g. `portfolio-backend`, `portfolio-frontend`), not full URIs.

## Structure

- **global/** — Shared ECR repositories (one per app). Apply once.
- **environments/staging/** — Terraform root for staging (own state, own tfvars). Only entry point for staging.
- **environments/prod/** — Terraform root for prod (own state, own tfvars). Only entry point for prod.
- **modules/portfolio** — Shared logic: ECR data sources + VPC + ALB + ECS. Each environment’s `main.tf` just sets backend, provider, and calls this module with different variables; no duplicated resource definitions.
- **modules/vpc**, **modules/alb**, **modules/ecs** — Building blocks used by `portfolio`.

There is no `main.tf` at the `infra/` root; all applies run from `global/` or `environments/<env>/`.

## Service communication

- **User → ALB → Frontend/Backend:** The ALB receives public traffic and routes `/` to the frontend and `/health`, `/assets`, `/insights` to the backend.
- **Frontend → Backend (direct):** The frontend in ECS calls the backend via **private DNS** (AWS Cloud Map): `backend.portfolio-<env>.local:8000`. Traffic does not go through the ALB; it stays within the VPC between tasks. The backend registers in Cloud Map; the ECS security group allows traffic on port 8000 between tasks in the same SG.

## Validate with LocalStack (without AWS)

You can validate Terraform locally against [LocalStack](https://docs.localstack.cloud/):

1. **Install the `tflocal` wrapper** (points the provider endpoints to LocalStack):
   ```bash
   pip3 install terraform-local
   ```
   (If you don't have `pip3`: `python3 -m pip install terraform-local`.)
2. **Start LocalStack and run plan:**
   ```bash
   ./scripts/validate-localstack.sh plan
   ```
   Optional: `./scripts/validate-localstack.sh apply` to create resources in LocalStack (useful for testing; some ECS/ALB resources may have limitations in the community edition).

3. **Manual:** Start LocalStack, then run from an environment (e.g. staging) with LocalStack tfvars:
   ```bash
   docker compose -f docker-compose.localstack.yml up -d
   cp infra/terraform.tfvars.localstack.example infra/terraform.tfvars.localstack
   cd infra/environments/staging && tflocal init -backend=false && tflocal plan -var-file=../../terraform.tfvars.localstack
   ```

The script uses `terraform.tfvars.localstack` (copied from `.example` the first time); do not commit that file if you change values.

**LocalStack Community limitation:** The free edition does **not** include ECR, ELBv2 (ALB), ECS, or Service Discovery; they require a paid license. Therefore:
- **`tflocal plan`** can run and check syntax and dependencies between modules.
- **`tflocal apply`** will fail on ECR, ALB, ECS, and Cloud Map resources (501 / "not included within your LocalStack license").
- To validate the full stack without real AWS you need LocalStack Pro, or run **`terraform plan`** in AWS with credentials and real `terraform.tfvars`.

## Optional: custom domain

Set `domain_name` and `certificate_arn` in tfvars and create a CNAME (or alias) from your domain to the ALB DNS name.
