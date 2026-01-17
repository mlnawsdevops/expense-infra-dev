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