# Key decisions

- **IaC:** Terraform (not CDK). VPC in 3 layers: public (IGW, NAT, ALB), app (ECS Fargate), DB (internal only). State in S3; no DynamoDB for locking per preference.
- **Containers:** ECS Fargate with basic CPU/memory allocation. Two services: backend (FastAPI), frontend (Next.js standalone).
- **CI/CD:** GitHub Actions. OIDC for AWS. Branches: `staging` and `prod`. CI: lint, test, build, push to ECR. Deploy: staging on push to `staging`; prod on push to `prod` with manual approval (environment `production`).
- **Secrets / config:** SSM Parameter Store and Secrets Manager. Task definitions can reference them via `secrets` or env from SSM; document exact parameter names in runbooks.
- **Domain / TLS:** Default is ALB URL only. ALB module accepts optional `domain_name` and `certificate_arn` so we can add a custom domain and HTTPS later without changing module structure.
- **Observability:** CloudWatch Logs for ECS; alerting on CPU, memory, ALB 5xx, and unhealthy targets (see OBSERVABILITY.md).
- **Base images:** Backend: `python:3.12-slim`. Frontend: multi-stage with `node:20-alpine`; final runner `node:20-alpine`. Next.js `output: 'standalone'` for smaller image.
