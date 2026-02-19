resource "aws_ecs_cluster" "main" {
  name = "portfolio-${var.env}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "portfolio-${var.env}-cluster"
  }
}

# Execution role (pull images, logs)
resource "aws_iam_role" "execution" {
  name = "portfolio-${var.env}-ecs-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role (for app; can add SSM/Secrets access here)
resource "aws_iam_role" "task" {
  name = "portfolio-${var.env}-ecs-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

# ECS tasks security group: ALB → ECS; frontend → backend (same SG) for direct communication
resource "aws_security_group" "ecs" {
  name        = "portfolio-${var.env}-ecs-sg"
  description = "ECS: ALB and service-to-service (frontend→backend)"
  vpc_id      = var.vpc_id
  # ALB to backend and frontend
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  # Frontend → backend direct (Cloud Map private DNS); same SG
  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "portfolio-${var.env}-ecs-sg"
  }
}

# Backend task definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "portfolio-${var.env}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory_mb
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = var.backend_image
      essential    = true
      portMappings = [{ containerPort = 8000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/portfolio-${var.env}-backend"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "ENV", value = var.env }
      ]
    }
  ])
  tags = {
    Name = "portfolio-${var.env}-backend"
  }
}

# Frontend task definition: direct communication to backend via private DNS (Cloud Map)
locals {
  backend_url = "http://backend.portfolio-${var.env}.local:8000"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "portfolio-${var.env}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory_mb
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = var.frontend_image
      essential    = true
      portMappings = [{ containerPort = 3000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/portfolio-${var.env}-frontend"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "NODE_ENV", value = "production" },
        # Backend via private DNS (Cloud Map); direct frontend→backend traffic without ALB
        { name = "NEXT_PUBLIC_API_URL", value = local.backend_url }
      ]
    }
  ])
  tags = {
    Name = "portfolio-${var.env}-frontend"
  }
}

# CloudWatch log groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/portfolio-${var.env}-backend"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/portfolio-${var.env}-frontend"
  retention_in_days = 14
}

data "aws_region" "current" {}

# Service discovery: private DNS so frontend can call backend without going through the ALB
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "portfolio-${var.env}.local"
  description = "Private DNS for ECS service discovery"
  vpc         = var.vpc_id
  tags = {
    Name = "portfolio-${var.env}-sd-namespace"
  }
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.main.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  tags = {
    Name = "portfolio-${var.env}-backend"
  }
}

# Backend service (registered in Cloud Map for frontend→backend private DNS)
resource "aws_ecs_service" "backend" {
  name            = "portfolio-${var.env}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.app_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.alb_backend_tg_arn
    container_name   = "backend"
    container_port   = 8000
  }
  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }
  depends_on = [aws_cloudwatch_log_group.backend]
  tags = {
    Name = "portfolio-${var.env}-backend"
  }
}

# Frontend service
resource "aws_ecs_service" "frontend" {
  name            = "portfolio-${var.env}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.app_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.alb_frontend_tg_arn
    container_name   = "frontend"
    container_port   = 3000
  }
  depends_on = [aws_cloudwatch_log_group.frontend]
  tags = {
    Name = "portfolio-${var.env}-frontend"
  }
}
