# SNS topic for CloudWatch alarms
resource "aws_sns_topic" "alarms" {
  name = "portfolio-${var.env}-alarms"
  tags = {
    Name = "portfolio-${var.env}-alarms"
  }
}

# Allow CloudWatch to publish to this topic
resource "aws_sns_topic_policy" "alarms" {
  arn = aws_sns_topic.alarms.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.alarms.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}

# Email subscription (only when alarm_email is set)
resource "aws_sns_topic_subscription" "alarms_email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- ECS Backend alarms ---

resource "aws_cloudwatch_metric_alarm" "backend_cpu" {
  alarm_name          = "portfolio-${var.env}-backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.alarm_cpu_threshold_percent
  alarm_description   = "ECS backend CPU utilization above ${var.alarm_cpu_threshold_percent}%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.backend_service_name
  }
  tags = {
    Name = "portfolio-${var.env}-backend-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_memory" {
  alarm_name          = "portfolio-${var.env}-backend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.alarm_memory_threshold_percent
  alarm_description   = "ECS backend memory utilization above ${var.alarm_memory_threshold_percent}%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.backend_service_name
  }
  tags = {
    Name = "portfolio-${var.env}-backend-memory-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_no_tasks" {
  alarm_name          = "portfolio-${var.env}-backend-no-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "ECS backend has no running tasks"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.backend_service_name
  }
  tags = {
    Name = "portfolio-${var.env}-backend-no-tasks"
  }
}

# --- ECS Frontend alarms ---

resource "aws_cloudwatch_metric_alarm" "frontend_cpu" {
  alarm_name          = "portfolio-${var.env}-frontend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.alarm_cpu_threshold_percent
  alarm_description   = "ECS frontend CPU utilization above ${var.alarm_cpu_threshold_percent}%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.frontend_service_name
  }
  tags = {
    Name = "portfolio-${var.env}-frontend-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_memory" {
  alarm_name          = "portfolio-${var.env}-frontend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.alarm_memory_threshold_percent
  alarm_description   = "ECS frontend memory utilization above ${var.alarm_memory_threshold_percent}%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.frontend_service_name
  }
  tags = {
    Name = "portfolio-${var.env}-frontend-memory-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_no_tasks" {
  alarm_name          = "portfolio-${var.env}-frontend-no-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "ECS frontend has no running tasks"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.frontend_service_name
  }
  tags = {
    Name = "portfolio-${var.env}-frontend-no-tasks"
  }
}
