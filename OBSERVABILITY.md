# Observability

## Logging

### Structured logging configuration

- **Backend:** Application-level structured logging is configured in code (`app/logging_config.py`). Uses [structlog](https://www.structlog.org/) to emit **JSON logs to stdout** (one line per event with `timestamp`, `level`, `event`, and custom keys such as `method`, `path`, `status_code`). Set `LOG_JSON=false` for human-readable console output in local dev. ECS captures stdout via the `awslogs` driver and sends it to CloudWatch.
- **Frontend:** Next.js writes to stdout/stderr; ECS captures it with `awslogs` and sends it to CloudWatch. For structured (JSON) logs in the frontend, add a logger such as [pino](https://github.com/pinojs/pino) or winston with a JSON transport in a future iteration; current setup satisfies aggregation and search in CloudWatch Logs.

### Transport and retention

- **Backend / Frontend:** Log streams are sent to CloudWatch Logs via the `awslogs` driver in ECS task definitions (see `infra/modules/ecs/main.tf`). Log groups: `/ecs/portfolio-<env>-backend`, `/ecs/portfolio-<env>-frontend`. Retention: 14 days (configurable in Terraform).
- **Aggregation:** CloudWatch Logs Insights can query across log groups. Optionally export to S3 or a third-party (e.g. Datadog) via subscription filters.

## Metrics to collect

- **ECS:** CPUUtilization, MemoryUtilization per service (default in Container Insights).
- **ALB:** RequestCount, TargetResponseTime, HTTPCode_Target_5XX_Count, UnHealthyHostCount.
- **Application:** Backend can expose Prometheus-style metrics later; for now rely on ECS/ALB.

## Alerting (recommended)

- **CPU / Memory:** CloudWatch alarms on ECS service CPUUtilization and MemoryUtilization (e.g. > 80% for 2 periods).
- **ALB 5xx:** Alarm on HTTPCode_Target_5XX_Count > 0 (or threshold).
- **Unhealthy targets:** Alarm on UnHealthyHostCount > 0.
- **Optional:** Latency (TargetResponseTime) and request count (RequestCount) for capacity planning.

Alarms can notify SNS → email, Slack, or PagerDuty. Define these in Terraform (optional) or in the AWS console.

## Dashboards

- **Layout:** One dashboard per environment with panels for ECS CPU/Memory, ALB request count, 5xx, latency, and unhealthy hosts. Use CloudWatch dashboards or Grafana with CloudWatch data source.
