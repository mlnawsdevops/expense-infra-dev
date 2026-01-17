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

resource "aws_security_group_rule" "mysql_backend" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.backend_sg.id #requestor backend to acces mysql database
    security_group_id = module.mysql_sg.id #acceptor
}

resource "aws_security_group_rule" "backend_frontend" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    source_security_group_id = module.frontend_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_backend_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.backend_sg.id
    security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "backend_frontend_22" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.frontend_sg.id
    security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_public" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "mysql_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
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

resource "aws_security_group_rule" "mysql_ansible" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.ansible_sg.id
    security_group_id = module.mysql_sg.id
}

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
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.ansible_sg.id
}