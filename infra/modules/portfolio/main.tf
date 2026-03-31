# Shared environment logic: ECR data, VPC, ALB, ECS. Used by environments/staging and environments/prod.

data "aws_ecr_repository" "backend" {
  name = "portfolio-backend"
}

data "aws_ecr_repository" "frontend" {
  name = "portfolio-frontend"
}

module "vpc" {
  source   = "../vpc"
  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
  env      = var.environment
}

module "alb" {
  source            = "../alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  env               = var.environment
  certificate_arn   = var.certificate_arn
}

module "ecs" {
  source                = "../ecs"
  env                   = var.environment
  vpc_id                = module.vpc.vpc_id
  app_subnet_ids        = module.vpc.app_subnet_ids
  backend_image         = var.backend_image
  frontend_image        = var.frontend_image
  alb_backend_tg_arn    = module.alb.backend_target_group_arn
  alb_frontend_tg_arn   = module.alb.frontend_target_group_arn
  alb_security_group_id = module.alb.security_group_id
  ecs_cpu               = var.ecs_cpu
  ecs_memory_mb         = var.ecs_memory_mb
  allowed_origins       = var.allowed_origins
}

module "cloudwatch_alarms" {
  source                           = "../cloudwatch-alarms"
  env                              = var.environment
  alarm_email                      = var.alarm_email
  cluster_name                     = module.ecs.cluster_name
  backend_service_name             = module.ecs.backend_service_name
  frontend_service_name            = module.ecs.frontend_service_name
  alb_load_balancer_dimension      = module.alb.alb_load_balancer_dimension
  backend_target_group_arn_suffix  = module.alb.backend_target_group_arn_suffix
  frontend_target_group_arn_suffix = module.alb.frontend_target_group_arn_suffix
}
