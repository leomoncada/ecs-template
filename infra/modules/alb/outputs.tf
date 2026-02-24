output "alb_id" {
  value = aws_lb.main.id
}

output "alb_arn" {
  value = aws_lb.main.arn
}

# For CloudWatch ALB metrics (dimension LoadBalancer value = app/name/id)
output "alb_load_balancer_dimension" {
  value       = replace(aws_lb.main.arn_suffix, "loadbalancer/", "")
  description = "LoadBalancer dimension value for CloudWatch ALB metrics"
}

output "dns_name" {
  value = aws_lb.main.dns_name
}

output "zone_id" {
  value = aws_lb.main.zone_id
}

output "security_group_id" {
  value = aws_security_group.alb.id
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}

# For CloudWatch target group metrics (dimension TargetGroup)
output "backend_target_group_arn_suffix" {
  value       = aws_lb_target_group.backend.arn_suffix
  description = "ARN suffix for backend target group"
}

output "frontend_target_group_arn_suffix" {
  value       = aws_lb_target_group.frontend.arn_suffix
  description = "ARN suffix for frontend target group"
}
