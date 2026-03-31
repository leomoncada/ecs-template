variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "env" {
  type = string
}

variable "certificate_arn" {
  type    = string
  default = ""
}
