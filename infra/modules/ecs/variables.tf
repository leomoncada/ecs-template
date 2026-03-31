variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "backend_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "alb_backend_tg_arn" {
  type = string
}

variable "alb_frontend_tg_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_cpu" {
  type    = number
  default = 256
}

variable "ecs_memory_mb" {
  type    = number
  default = 512
}

variable "allowed_origins" {
  type        = string
  default     = "http://localhost:3000"
  description = "Comma-separated list of allowed CORS origins for the backend (e.g. https://app.example.com)"
}

# Optional: ARNs of secrets/parameters the task is allowed to read (least privilege)
variable "task_secrets_manager_arns" {
  type        = list(string)
  default     = []
  description = "ARNs of Secrets Manager secrets the ECS task role can read (e.g. DB credentials)"
}

variable "task_ssm_parameter_arns" {
  type        = list(string)
  default     = []
  description = "ARNs of SSM Parameter Store parameters the ECS task role can read"
}

# Autoscaling
variable "autoscaling_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of tasks per ECS service"
}

variable "autoscaling_max_capacity" {
  type        = number
  default     = 4
  description = "Maximum number of tasks per ECS service"
}

variable "autoscaling_target_cpu_percent" {
  type        = number
  default     = 70
  description = "Target CPU utilization percentage for scaling"
}

variable "autoscaling_target_memory_percent" {
  type        = number
  default     = 80
  description = "Target memory utilization percentage for scaling"
}
