# Create an Application Load Balancer
resource "aws_lb" "lb" {
  name               = "gpac-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnet_ids

  tags = {
    Name = "frontend-lb"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
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

# HTTPS Listener (Using SSL Certificate)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# Define a Target Group to register instances
resource "aws_lb_target_group" "lb_target_group" {
  name     = "gpac-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# Attach instances to the Target Group
resource "aws_lb_target_group_attachment" "lb_target_group_attachement" {
  count            = length(var.target_instance_ids) # Loop over the list of instance IDs
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = var.target_instance_ids[count.index]
  port             = 80
}
