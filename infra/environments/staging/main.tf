terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "portfolio/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "your-terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

module "portfolio" {
  source = "../../modules/portfolio"

  aws_region      = var.aws_region
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  az_count        = var.az_count
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  backend_image   = var.backend_image
  frontend_image  = var.frontend_image
  ecs_cpu         = var.ecs_cpu
  ecs_memory_mb   = var.ecs_memory_mb
  alarm_email     = var.alarm_email
  allowed_origins = var.allowed_origins
}
