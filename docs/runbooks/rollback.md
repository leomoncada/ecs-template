# Runbook: Rollback ECS deployment

Use this when a new deployment causes errors (5xx, broken UI, or failed health checks) and you need to revert to the previous task definition or image.

## Option 1: Redeploy previous image tag (recommended)

If you previously promoted a known-good image to `prod` (or use `staging`), you can re-tag and force a new deployment.

1. **Identify the last known good image** in ECR (e.g. by digest or an older tag like `staging` or a specific SHA tag from CI).
2. **Re-tag that image as `prod`** (or the tag your ECS service uses):
   ```bash
   # Example: promote staging (or a specific digest) to prod again
   aws ecr batch-get-image --repository-name portfolio-backend --image-ids imageTag=staging \
     --query 'images[0].imageManifest' --output text > /tmp/manifest.json
   aws ecr put-image --repository-name portfolio-backend --image-tag prod --image-manifest file:///tmp/manifest.json
   # Repeat for portfolio-frontend if needed.
   ```
3. **Force a new ECS deployment** so the service pulls the re-tagged image:
   ```bash
   aws ecs update-service --cluster portfolio-prod-cluster --service portfolio-prod-backend --force-new-deployment --region us-east-1
   aws ecs update-service --cluster portfolio-prod-cluster --service portfolio-prod-frontend --force-new-deployment --region us-east-1
   ```
4. Wait for the deployment to reach `RUNNING` (ECS console or `aws ecs describe-services`).

## Option 2: Roll back to previous task definition revision

If ECS is using a specific task definition revision and the new one is broken:

1. In **ECS console**: Cluster → Service → Update service → Revision: select the previous revision → Update.
2. Or with CLI:
   ```bash
   # List task definition revisions
   aws ecs list-task-definitions --family-prefix portfolio-prod-backend
   # Update service to use previous revision (e.g. portfolio-prod-backend:42)
   aws ecs update-service --cluster portfolio-prod-cluster --service portfolio-prod-backend \
     --task-definition portfolio-prod-backend:42 --force-new-deployment --region us-east-1
   ```

## After rollback

- Confirm alarms return to OK (CloudWatch) and `/health` and the UI work.
- Investigate the bad deploy (logs, diff) and fix before deploying again.
