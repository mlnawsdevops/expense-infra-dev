variable "zone_name" {
    default = "daws100s.online"
}

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
        Component = "acm"
        Terraform = "true"
    }
}

variable "zone_id" {
  default = "Z02305702LFJSCAA8YV7Q"
}