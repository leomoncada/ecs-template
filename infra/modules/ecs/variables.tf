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
