#!/usr/bin/env bash
# Start LocalStack and validate Terraform with tflocal (plan or apply).
# Requirements: Docker, pip install terraform-local
# Usage: ./scripts/validate-localstack.sh [plan|apply]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ACTION="${1:-plan}"
COMPOSE_FILE="$REPO_ROOT/docker-compose.localstack.yml"
INFRA_ROOT="$REPO_ROOT/infra"
TFVARS_LOCAL="$INFRA_ROOT/terraform.tfvars.localstack"
TFVARS_EXAMPLE="$INFRA_ROOT/terraform.tfvars.localstack.example"
ENV_DIR="$INFRA_ROOT/environments/staging"

cd "$REPO_ROOT"

if [ "$ACTION" != "plan" ] && [ "$ACTION" != "apply" ]; then
  echo "Usage: $0 [plan|apply]"
  exit 1
fi
if [ "$ACTION" = "apply" ]; then
  echo "Note: LocalStack Community does not include ECR, ALB, ECS or Service Discovery; apply will fail on those resources."
  echo "      Use 'plan' to validate syntax or deploy to real AWS to validate the full stack."
fi

# tflocal may not be in PATH if installed with pip --user; add Python user bin
PYTHON_USER_BIN=$(python3 -c "import site; print(site.USER_BASE + '/bin')" 2>/dev/null || true)
if [ -n "$PYTHON_USER_BIN" ] && [ -d "$PYTHON_USER_BIN" ]; then
  export PATH="$PYTHON_USER_BIN:$PATH"
fi
if command -v tflocal &>/dev/null; then
  TFLOCAL="tflocal"
elif python3 -c "import importlib.metadata; importlib.metadata.distribution('terraform-local')" 2>/dev/null; then
  TFLOCAL="python3 -m terraform_local"
else
  echo "tflocal not found. Install with:"
  echo "  python3 -m pip install terraform-local"
  echo "If already installed, add Python scripts directory to PATH:"
  echo "  export PATH=\"\$HOME/Library/Python/3.9/bin:\$PATH\""
  exit 1
fi

echo "==> Starting LocalStack..."
# Remove any existing container named 'localstack' to avoid "container name already in use" conflict
docker rm -f localstack 2>/dev/null || true
docker compose -f "$COMPOSE_FILE" up -d

echo "==> Waiting for LocalStack to respond..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:4566/_localstack/health >/dev/null 2>&1; then
    echo "    LocalStack ready."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "    Timeout waiting for LocalStack."
    exit 1
  fi
  sleep 2
done

cd "$ENV_DIR"

if [ -f "$TFVARS_EXAMPLE" ] && [ ! -f "$TFVARS_LOCAL" ]; then
  echo "==> Creating $TFVARS_LOCAL from example..."
  cp "$TFVARS_EXAMPLE" "$TFVARS_LOCAL"
fi

VAR_FILE=""
if [ -f "$TFVARS_LOCAL" ]; then
  VAR_FILE="-var-file=$TFVARS_LOCAL"
fi

echo "==> tflocal init (from environments/staging, backend in LocalStack S3)..."
$TFLOCAL init -input=false

echo "==> tflocal $ACTION $VAR_FILE..."
$TFLOCAL $ACTION -input=false $VAR_FILE

echo ""
echo "LocalStack validation completed."
echo "Note: In the community edition, ECR/ALB/ECS/ServiceDiscovery are not included; apply will fail on those resources. Use 'plan' to validate syntax or LocalStack Pro / real AWS for full apply."
