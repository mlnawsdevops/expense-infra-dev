locals {
    resource_name = "${var.project_name}-${var.environment}-bastion"
    bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
    bastion_subnet_ids = split(",",data.aws_ssm_parameter.public_subnet_ids.value)
}