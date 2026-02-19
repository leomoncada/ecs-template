output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "alb_dns_name" {
  value       = module.alb.dns_name
  description = "ALB DNS name (use this URL when domain_name is not set)"
}

output "alb_zone_id" {
  value       = module.alb.zone_id
  description = "ALB Route53 zone ID (for optional alias record)"
}

output "ecr_backend_url" {
  value       = data.aws_ecr_repository.backend.repository_url
  description = "ECR backend repository URL (shared; use tag staging or prod)"
}

output "ecr_frontend_url" {
  value       = data.aws_ecr_repository.frontend.repository_url
  description = "ECR frontend repository URL (shared; use tag staging or prod)"
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "ECS cluster name"
}

output "ecs_backend_service_name" {
  value       = module.ecs.backend_service_name
  description = "ECS backend service name"
}

output "ecs_frontend_service_name" {
  value       = module.ecs.frontend_service_name
  description = "ECS frontend service name"
}
