# Runbook: Incidents and alerts

## Alarm: ALB 5xx (portfolio-*-alb-5xx)

**Meaning:** The Application Load Balancer returned 5xx responses (server errors) above the threshold.

**Actions:**

1. **Check ECS services:** In ECS console, confirm backend and frontend services have running tasks. If desired count is 0 or tasks are failing, see “No running tasks” below.
2. **Check target health:** ALB → Target groups → Backend/Frontend → Targets. Unhealthy targets can cause 5xx.
3. **Check application logs:** CloudWatch Logs → log groups `/ecs/portfolio-<env>-backend` and `/ecs/portfolio-<env>-frontend`. Look for exceptions, OOM, or startup failures.
4. **Recent deploy:** If a deploy was done recently, consider a [rollback](rollback.md) to the previous image.

---

## Alarm: Unhealthy hosts (backend or frontend target group)

**Meaning:** At least one target in the group is unhealthy (health check failing).

**Actions:**

1. **Target group → Targets:** See which instance(s) are unhealthy and the failure reason (e.g. timeout, non-2xx).
2. **Logs:** Check the corresponding ECS service logs in CloudWatch for that service (backend: `/health` and app errors; frontend: startup and route errors).
3. **Task definition / image:** Bad image or misconfigured health check path can cause this. Compare with last working deploy; consider rollback.

---

## Alarm: ECS no running tasks (backend or frontend)

**Meaning:** The ECS service has zero running tasks (e.g. all stopped or failed).

**Actions:**

1. **ECS console:** Cluster → Service → Events. Look for failure reasons (e.g. resource, pull, health check).
2. **Stopped tasks:** In the service, open “Tasks” and filter by Stopped; open a failed task and check “Stopped reason”.
3. **Common causes:**
   - Image pull failure (ECR permissions, wrong tag).
   - Container exit: check CloudWatch Logs for the service.
   - Resource (CPU/memory) or placement (subnet/SG) issues.
4. **Immediate fix:** From Runbook [Deploy](deploy.md), trigger a new deployment (e.g. re-run deploy workflow or `aws ecs update-service ... --force-new-deployment`). If the current image is bad, do a [rollback](rollback.md) first.

---

## Alarm: ECS CPU or memory high

**Meaning:** Service CPU or memory utilization is above the configured threshold (autoscaling may already be adding tasks).

**Actions:**

1. **ECS service:** Check current task count and scaling; consider raising max capacity if needed.
2. **Logs and metrics:** Look for spikes (traffic, a slow or leaking process). Optimize or scale as needed.
3. **Task size:** Consider increasing CPU/memory in the task definition (Terraform: `ecs_cpu`, `ecs_memory_mb`) if tasks are consistently near limit.

---

## Accessing logs quickly

- **Backend:** CloudWatch Logs → `/ecs/portfolio-<env>-backend`
- **Frontend:** CloudWatch Logs → `/ecs/portfolio-<env>-frontend`

Use the log stream of the latest task (or filter by time) to inspect errors around the alarm time.
