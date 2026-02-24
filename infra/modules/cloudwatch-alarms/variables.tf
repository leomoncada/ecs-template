variable "env" {
  type        = string
  description = "Environment name (e.g. staging, prod)"
}

variable "alarm_email" {
  type        = string
  default     = ""
  description = "Email address for alarm notifications. Leave empty to create topic without subscription."
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "backend_service_name" {
  type        = string
  description = "ECS backend service name"
}

variable "frontend_service_name" {
  type        = string
  description = "ECS frontend service name"
}

# ALB dimensions for 5xx and UnHealthyHostCount alarms (optional; set to empty string to skip ALB alarms)
variable "alb_load_balancer_dimension" {
  type        = string
  default     = ""
  description = "LoadBalancer dimension value (app/name/id) for ALB CloudWatch metrics"
}

variable "backend_target_group_arn_suffix" {
  type        = string
  default     = ""
  description = "Target group ARN suffix for backend (targetgroup/name/id)"
}

variable "frontend_target_group_arn_suffix" {
  type        = string
  default     = ""
  description = "Target group ARN suffix for frontend (targetgroup/name/id)"
}

variable "alarm_alb_5xx_threshold" {
  type        = number
  default     = 5
  description = "Number of ALB 5xx responses in period to trigger alarm"
}

variable "alarm_alb_unhealthy_hosts_threshold" {
  type        = number
  default     = 1
  description = "UnHealthyHostCount threshold to trigger alarm"
}

variable "alarm_cpu_threshold_percent" {
  type        = number
  default     = 85
  description = "CPU utilization threshold (percent) to trigger alarm"
}

variable "alarm_memory_threshold_percent" {
  type        = number
  default     = 90
  description = "Memory utilization threshold (percent) to trigger alarm"
}

variable "alarm_evaluation_periods" {
  type        = number
  default     = 2
  description = "Number of periods the threshold must be breached to trigger alarm"
}

variable "alarm_period_seconds" {
  type        = number
  default     = 300
  description = "Period length in seconds for metric evaluation"
}
