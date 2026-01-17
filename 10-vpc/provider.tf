terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.27.0"
        }
    }
    backend "s3" {
        bucket = "100s-remote--state"
        key = "expense-infra-vpc-dev"
        region = "us-east-1"
        dynamodb_table = "100s-locking"
    }
}

provider "aws" {
    region = "us-east-1"
}