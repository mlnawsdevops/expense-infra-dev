variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Component = "mysql"
        Terraform = "true"
    }
}

variable "rds_tags" {
    default = {
        Component = "mysql"
    }
}