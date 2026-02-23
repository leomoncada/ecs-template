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
