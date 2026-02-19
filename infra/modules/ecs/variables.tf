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
