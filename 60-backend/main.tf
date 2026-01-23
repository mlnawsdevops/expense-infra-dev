## session-37
# 1. create ec2-instance for backend
# 2. configure the instance using ansible 
# 3. null resource and connect instance using remote provisioners and file provisioners.
# 4. stop the instance using resource "aws_ec2_instance_state"
# 5. take the instance ami using "aws_ami_from_instance"
# 6. delete the instance using null resource and aws command line arguments and local exec.
# 7. create targetgroup
# 8. create launch template
# 9. create autoscalinggroup
# 10. create autoscalinggroup policy
# 11. create lb listener rule


module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = local.ami_id
  name = local.resource_name #expense-dev-backend

  instance_type = "t3.micro"

  # bastion security group from 20-sg
  vpc_security_group_ids = [local.backend_sg_id]

  # us-east-1a(10.0.1.0 - 10.0.1.255)/24 = 256 private ip addresses availability zone bastion-expense-dev server 
  subnet_id = local.private_subnet_id
  
  create_security_group = false 

  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
      Name = local.resource_name
    }
  )
}

# null resource it won't create any resources. just using for provisioners connection
resource "null_resource" "backend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.backend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh",
      "sudo sh /tmp/backend.sh ${var.backend_tags.Component} ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  depends_on = [null_resource.backend]
}

resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = module.backend.id
  depends_on = [aws_ec2_instance_state.backend]
}

resource "null_resource" "delete_backend" {
  triggers = {
    instance_id = module.backend.id
  }

  provisioner "local-exec" {
    # aws command to terminate ec2 instances
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
  }
  depends_on = [aws_ami_from_instance.backend]
}

resource "aws_lb_target_group" "backend" {
  name     = local.resource_name
  port     = 8080 # backend netstat open port 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold = 2 # if 2 request are success then healthy
    unhealthy_threshold = 2 # Number of consecutive health check failures required before considering the target unhealthy
    interval = 5 # Approximate amount of time, in seconds, between health checks of an individual target
    matcher = "200-299" #success response
    path = "/health"
    port = 8080 # backend port
    protocol = "HTTP" # no secure requests
    timeout = 4 # Amount of time, in seconds, during which no response means a failed health check
  }
}

resource "aws_launch_template" "backend" {
  name = local.resource_name
  image_id = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate" # when instance is shutdown it will go to terminate not stop
  update_default_version = true
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }
}

resource "aws_autoscaling_group" "backend" {
  name = "${local.resource_name}-asg"
  max_size = 10
  min_size = 2
  health_check_grace_period = 180 # 180 better to up the instaces health
  health_check_type = "ELB"
  desired_capacity = 2 # starting of the auto scaling group
  target_group_arns = [aws_lb_target_group.backend.arn]

  launch_template {
    id = aws_launch_template.backend.id
    version = "$Latest"
  }

# rolling update of instances, percentage means avg to instances
# for 4 instances, 50% percent means 2instances always will during upgrade
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  
  vpc_zone_identifier = [local.private_subnet_id]

  tag {
    key = "name"
    value = local.resource_name
    propagate_at_launch = true
  }

  # if instances are not healthy within 15min, autoscaling will that delete autoscaling
  timeouts {
    delete = "15m"
  }

  tag {
    key = "Project"
    value = "expense"
    propagate_at_launch = false
  }
}


resource "aws_autoscaling_policy" "backend" {
  name  = local.resource_name
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}


resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 100 # low priority will be evaluated first

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      # backend.app-dev.daws100s.online configured in frontend config 
      # all frontend instances requests reach to below record and then backend target group will trigger the backend instances
      values = ["${var.backend_tags.Component}.app-${var.environment}.${var.zone_name}"]
    }
  }
}
