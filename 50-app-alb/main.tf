# module for app lb
module "app_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal = true                # no public access
  name     = local.resource_name # expense-dev-app-alb
  vpc_id   = local.vpc_id
  subnets  = local.private_subnet_ids

  security_groups       = [local.app_alb_sg_id]
  create_security_group = false
  enable_deletion_protection = false
  tags = merge(
    var.common_tags,
    var.app_alb_tags,
    {
      Name = local.resource_name
    }
  )
}

# terraform aws app lb listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action { # action means rule
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Application LB</h1>"
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
      name = "*.app-${var.environment}"
      type = "A"
      alias = {
        name    = module.app_alb.dns_name
        zone_id = module.app_alb.zone_id
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
