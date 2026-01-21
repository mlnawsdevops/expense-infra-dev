variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project     = "expense"
    Environment = "dev"
    Component   = "app-alb-dev"
    Terraform   = "teue"
  }
}

variable "app_alb_tags" {
  default = {
    Component = "app-alb"
  }
}

variable "zone_name" {
  default = "daws100s.online"
}

variable "route53_tags" {
  default = {}
}