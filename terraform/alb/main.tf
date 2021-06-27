locals {
  # only create resources if enabled
  https_redirect_enabled  = var.https_redirect_enabled ? 1 : 0
  ssl_termination_enabled = var.ssl_termination_enabled ? 1 : 0

  # if allow_cloudflare is true, use IPs from the data source
  # otherwise, use the list provided in inbound_ips
  # this is VERY UGLY way to strip hereodc and empty lines, but it works :sob:
  inbound_ips = var.allow_cloudflare ? split("\n", chomp(data.http.cloudflare_ips[0].body)) : var.inbound_ips

}

### get cloudflare IPs 
data "http" "cloudflare_ips" {
  # only run if allow_cloudflare is true
  count = var.allow_cloudflare ? 1 : 0
  url   = "https://www.cloudflare.com/ips-v4"
}


resource "aws_lb" "ctfd_alb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_facing.id]
  subnets            = var.subnets

  enable_deletion_protection = false
  tags = {
    application = "ctfd"
  }
}

resource "aws_lb_target_group" "ctfd_target_group" {
  name        = "ctfd-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "https_forward" {
  count             = local.ssl_termination_enabled
  load_balancer_arn = aws_lb.ctfd_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ctfd_target_group.arn
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  count             = local.https_redirect_enabled
  load_balancer_arn = aws_lb.ctfd_alb.arn
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


resource "aws_lb_listener" "http_only" {
  count             = local.https_redirect_enabled == 0 && local.ssl_termination_enabled == 0 ? 1 : 0
  load_balancer_arn = aws_lb.ctfd_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ctfd_target_group.arn
  }
}

resource "aws_security_group" "public_facing" {
  name        = "public-facing rules"
  description = "rules for allowing inbound from the public internet"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    # dynamic blocks require an interable, so let's pretend
    for_each = local.https_redirect_enabled == 1 ? [1] : []
    content {
      description = "HTTPS from public internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.inbound_ips
    }
  }

  dynamic "ingress" {
    for_each = local.https_redirect_enabled == 0 ? [1] : []
    content {
      description = "HTTP from public internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.inbound_ips
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
