variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "Expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "mysql_sg_tags" {
    default = {}
}

variable "backend_sg_tags" {
    default = {}
}

variable "frontend_sg_tags" {
    default = {}
}

variable "bastion_sg_tags" {
    default = {}
}

variable "ansible_sg_tags" {
    default = {}
}

variable "app_alb_sg_tags" {
    default = {
        Component = "app-alb"
    }
}

variable "web_alb_sg_tags" {
    default = {
        Component = "web-alb"
    }
}

variable "vpn_sg_tags" {
    default = {
        Component = "vpn"
    }
}