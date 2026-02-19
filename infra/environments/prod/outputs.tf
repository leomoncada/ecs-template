output "vpc_id" {
  value       = module.portfolio.vpc_id
  description = "VPC ID"
}

output "alb_dns_name" {
  value       = module.portfolio.alb_dns_name
  description = "ALB DNS name (dashboard URL)"
}

output "alb_zone_id" {
  value       = module.portfolio.alb_zone_id
  description = "ALB Route53 zone ID"
}

output "ecr_backend_url" {
  value       = module.portfolio.ecr_backend_url
  description = "ECR backend repository URL"
}

output "ecr_frontend_url" {
  value       = module.portfolio.ecr_frontend_url
  description = "ECR frontend repository URL"
}

output "ecs_cluster_name" {
  value       = module.portfolio.ecs_cluster_name
  description = "ECS cluster name"
}

output "ecs_backend_service_name" {
  value       = module.portfolio.ecs_backend_service_name
  description = "ECS backend service name"
}

output "ecs_frontend_service_name" {
  value       = module.portfolio.ecs_frontend_service_name
  description = "ECS frontend service name"
}
