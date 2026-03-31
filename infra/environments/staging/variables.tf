variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use (2 or 3)"
  type        = number
  default     = 2
}

variable "domain_name" {
  description = "Optional domain name for the ALB. Leave empty to use ALB URL only."
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS."
  type        = string
  default     = ""
}

variable "backend_image" {
  description = "Backend ECR image URI (use tag :staging)"
  type        = string
}

variable "frontend_image" {
  description = "Frontend ECR image URI (use tag :staging)"
  type        = string
}

variable "ecs_cpu" {
  description = "CPU units per task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "ecs_memory_mb" {
  description = "Memory per task (MB)"
  type        = number
  default     = 512
}

variable "alarm_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

variable "allowed_origins" {
  description = "Comma-separated allowed CORS origins for the backend"
  type        = string
  default     = "http://localhost:3000"
}
