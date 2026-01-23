variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Component = "frontend"
    Environment = "dev"
    Terraform = "True"
  }
}

variable "frontend_tags" {
    default = {
        Component = "frontend"
    }
}

variable "zone_name" {
  default = "daws100s.online"
}