variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Component = "vpn"
        Environment = "dev"
        Terraform = "True"
    }
}

variable "vpn_tags" {
    default = {
        Component = "vpn"
    }
}