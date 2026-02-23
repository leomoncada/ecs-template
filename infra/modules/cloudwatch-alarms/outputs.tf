output "sns_topic_arn" {
  value       = aws_sns_topic.alarms.arn
  description = "ARN of the SNS topic used for alarm notifications"
}

output "sns_topic_name" {
  value       = aws_sns_topic.alarms.name
  description = "Name of the SNS topic"
}
