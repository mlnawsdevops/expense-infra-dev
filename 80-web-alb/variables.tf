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
    Component   = "web-alb-dev"
    Terraform   = "true"
  }
}

variable "web_alb_tags" {
  default = {
    Component = "web-alb"
  }
}

variable "zone_name" {
  default = "daws100s.online"
}

variable "route53_tags" {
  default = {}
}