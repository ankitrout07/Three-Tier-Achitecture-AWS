# External ALB (Public)
resource "aws_lb" "external_alb" {
  name               = "${var.project_name}-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-external-alb"
  }
}

# External ALB Listener (HTTP)
resource "aws_lb_listener" "external_lb_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Web Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-web-tg"
  }
}

# Internal ALB (Private)
resource "aws_lb" "internal_alb" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = aws_subnet.app[*].id

  tags = {
    Name = "${var.project_name}-internal-alb"
  }
}

# Internal ALB Listener
resource "aws_lb_listener" "internal_lb_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "4000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# App Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-app-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-app-tg"
  }
}
