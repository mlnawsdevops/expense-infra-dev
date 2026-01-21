variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Component = "backend"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "backend_tags" {
    default = {
        Component = "backend"
    }
}