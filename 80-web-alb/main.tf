# module for app lb

module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal = false
  name     = local.resource_name # expense-dev-app-alb
  vpc_id   = local.vpc_id
  subnets  = local.public_subnet_ids

  security_groups       = [local.web_alb_sg_id]
  create_security_group = false
  enable_deletion_protection = false
  tags = merge(
    var.common_tags,
    var.web_alb_tags,
    {
      Name = local.resource_name
    }
  )
}

# terraform aws app lb listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action { # action means rule
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from WEB ALB http</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_ssm_parameter.https_certificate_arn.value

  default_action { # action means rule
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from WEB ALB https</h1>"
      status_code  = "200"
    }
  }
}

# creating route53 record for app lb dns name
module "zone" {
  source = "terraform-aws-modules/route53/aws"

  name        = var.zone_name
  create_zone = false

  records = {
    app_wildcard = {
      name = "expense-${var.environment}" # expense-dev.daws100s.online
      type = "A"
      alias = {
        name    = module.web_alb.dns_name # web loadbalancer name
        zone_id = module.web_alb.zone_id # web loadbalancer zone_id
      }
      allow_overwrite = true 
    }
  }

  tags = merge(
    var.common_tags,
    var.route53_tags,
    {
      Name = local.resource_name
    }
  )
}
