# Global resources (shared across environments)

Creates **one ECR repository per app** (`portfolio-backend`, `portfolio-frontend`) with no environment suffix. Staging and prod use the same repos and differ only by image tag (`:staging`, `:prod`).

- Apply this root **once** per AWS account/region before applying the main infra for staging or prod.
- Use a separate state (e.g. S3 key `portfolio/global/terraform.tfstate`) so it is not overwritten by per-env applies.
- CI builds and pushes only on `staging`; deploy to prod promotes the same image by retagging `staging` → `prod` in these repos.
