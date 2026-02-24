resource "aws_lb" "main" {
  name               = "portfolio-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  tags = {
    Name = "portfolio-${var.env}-alb"
  }
}

resource "aws_security_group" "alb" {
  name        = "portfolio-${var.env}-alb-sg"
  description = "ALB: allow HTTP/HTTPS"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "portfolio-${var.env}-alb-sg"
  }
}

# Target group: backend (port 8000)
resource "aws_lb_target_group" "backend" {
  name        = "portfolio-${var.env}-backend"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
  tags = {
    Name = "portfolio-${var.env}-backend-tg"
  }
}

# Target group: frontend (port 3000)
resource "aws_lb_target_group" "frontend" {
  name        = "portfolio-${var.env}-frontend"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
  tags = {
    Name = "portfolio-${var.env}-frontend-tg"
  }
}

# HTTP listener: forward to frontend when no certificate; redirect to HTTPS when certificate is set
resource "aws_lb_listener" "http_forward" {
  count             = var.certificate_arn != "" ? 0 : 1
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

locals {
  http_listener_arn = var.certificate_arn != "" ? aws_lb_listener.http_redirect[0].arn : aws_lb_listener.http_forward[0].arn
}

# Route backend paths to backend target group (on HTTP listener; HTTPS has its own rule below)
resource "aws_lb_listener_rule" "backend" {
  listener_arn = local.http_listener_arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    path_pattern {
      values = ["/health", "/health/*", "/assets", "/assets/*", "/insights", "/insights/*"]
    }
  }
}

# HTTPS listener when certificate is provided (production: use domain + ACM cert)
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "backend_https" {
  count        = var.certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    path_pattern {
      values = ["/health", "/health/*", "/assets", "/assets/*", "/insights", "/insights/*"]
    }
  }
}
