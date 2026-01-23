module "mysql_sg" {
    # source = "../../terraform-aws-security-group-child"
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.mysql_sg_tags
}

module "backend_sg" {
    # source = "../../terraform-aws-security-group-child"
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "backend"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.backend_sg_tags
}

module "frontend_sg" {
    # source = "../../terraform-aws-security-group-child"
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "frontend"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.frontend_sg_tags
}

module "bastion_sg" {
    # source = "../../terraform-aws-security-group-child"
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.bastion_sg_tags
}

module "ansible_sg" {
    # source = "../../terraform-aws-security-group-child"
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "ansible"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.ansible_sg_tags
}

module "app_alb_sg" {
    # source = "../../terraform-aws-security-group-child"
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app-alb"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.app_alb_sg_tags
}

module "vpn_sg" {
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "vpn"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.vpn_sg_tags
}

module "web_alb_sg" {
    source = "git::https://github.com/mlnawsdevops/terraform-aws-security-group-child.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "web-alb"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.web_alb_sg_tags
}

resource "aws_security_group_rule" "mysql_backend" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.backend_sg.id #requestor backend to acces mysql database
    security_group_id = module.mysql_sg.id #acceptor
}


# resource "aws_security_group_rule" "backend_frontend" {
#     type = "ingress"
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     source_security_group_id = module.frontend_sg.id
#     security_group_id = module.backend_sg.id
# }

# resource "aws_security_group_rule" "frontend_backend_ssh" {
#     type = "ingress"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     source_security_group_id = module.backend_sg.id
#     security_group_id = module.frontend_sg.id
# }

# resource "aws_security_group_rule" "backend_frontend_22" {
#     type = "ingress"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     source_security_group_id = module.frontend_sg.id
#     security_group_id = module.backend_sg.id
# }

# resource "aws_security_group_rule" "frontend_public" {
#     type = "ingress"
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     security_group_id = module.frontend_sg.id
# }

resource "aws_security_group_rule" "mysql_bastion" {
    type = "ingress"    
    # RDS does not allow SSH because it is a managed service. However, a bastion host can connect to RDS as a database client over port 3306 if the RDS security group allows it. SSH is only used to access EC2 instances, not RDS.
    from_port = 3306 
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.mysql_sg.id
}

resource "aws_security_group_rule" "backend_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "bastion_public" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.bastion_sg.id
}

# resource "aws_security_group_rule" "mysql_ansible" {
#     type = "ingress"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     source_security_group_id = module.ansible_sg.id
#     security_group_id = module.mysql_sg.id
# }

resource "aws_security_group_rule" "backend_ansible" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.ansible_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_ansible" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.ansible_sg.id
    security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "ansible_public" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # here placing company ip address 
    security_group_id = module.ansible_sg.id
}

resource "aws_security_group_rule" "backend_app_alb" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    source_security_group_id = module.app_alb_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "app_alb_bastion" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.app_alb_sg.id
}

resource "aws_security_group_rule" "vpn_public_22" {
    type = "ingress"
    from_port = 22 
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_443" {
    type = "ingress"
    from_port = 443 
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_943" {
    type = "ingress"
    from_port = 943 
    to_port = 943
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_1194" {
    type = "ingress"
    from_port = 1194
    to_port = 1194
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.id
}


resource "aws_security_group_rule" "app_alb_vpn" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.id
    security_group_id = module.app_alb_sg.id
}

resource "aws_security_group_rule" "backend_vpn_8080" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "backend_vpn_22" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "web_alb_https_443" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = module.web_alb_sg.id
}

resource "aws_security_group_rule" "web_alb_http_80" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = module.web_alb_sg.id
}

#vpn is there in public subnet and vpn connection to frontend instances
resource "aws_security_group_rule" "frontend_vpn" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.id
    security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "frontend_web_alb" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.web_alb_sg.id
    security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "app_alb_frontend" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.frontend_sg.id
    security_group_id = module.app_alb_sg.id
}