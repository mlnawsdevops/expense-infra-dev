# create frontend ec2 and frst setup 

module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.frontend_sg_id]
  subnet_id = local.public_subnet_id

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

## create null resource and configure frontend ec2 instance

resource "null_resource" "frontend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.frontend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.frontend.private_ip
    user = "ec2-user"
    password = "DevOps321"
    type = "ssh"
  }

  provisioner "file" {
    source = "frontend.sh"
    destination = "/tmp/frontend.sh"    
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/frontend.sh",
      "sudo sh /tmp/frontend.sh ${var.frontend_tags.Component} ${var.environment}"
    ]
  }
}

## stopping ec2 instance
resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state       = "stopped"
  depends_on = [null_resource.frontend]
}

# configured frontend ec2 instance ami id
resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = module.frontend.id
  depends_on = [ aws_ec2_instance_state.frontend ]
}

#deleting the configured frontend ec2 instance 
resource "null_resource" "frontend_delete" {
    triggers = {
      instance_id = module.frontend.id
    }

    provisioner "local-exec" {
      command = "aws ec2 terminate-instances --instance-ids ${module.frontend.id}"
    }
    depends_on = [ aws_ami_from_instance.frontend ]
    
}

# creating target group for frotnend load balancer
resource "aws_lb_target_group" "frontend" {
    name        = local.resource_name
    port        = 80 # targeting backend alb
    protocol    = "HTTP"
    vpc_id      = local.vpc_id

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        interval = 5
        matcher = "200-299"
        path = "/"
        port = 80
        protocol = "HTTP"
        timeout = 4
    }
}


resource "aws_launch_template" "frontend" {

  name = local.resource_name
  image_id = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"

  update_default_version = true
  vpc_security_group_ids = [local.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
        var.common_tags,
        var.frontend_tags,
        {
            Name = local.resource_name
        }
    )
  }
  
}

resource "aws_autoscaling_group" "frontend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 180
  health_check_type         = "ELB"
  desired_capacity          = 2
  target_group_arns = [aws_lb_target_group.frontend.arn]
  vpc_zone_identifier       = [local.public_subnet_id]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "expense"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "frontend" {
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  name                   = local.resource_name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}

resource "aws_lb_listener_rule" "example" {
  listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      # expense-dev.daws100s.online => web loadbalancer DNS name will hit frst and listener will listen and forward requests to specific target then instances will trigger 
      values = ["${var.project_name}-${var.environment}.${var.zone_name}"]
    }
  }
}