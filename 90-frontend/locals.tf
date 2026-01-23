locals {
  resource_name = "${var.project_name}-${var.environment}-frontend"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  ami_id = data.aws_ami.ami_info.id
  frontend_sg_id = data.aws_ssm_parameter.frontend_sg_id.value
  public_subnet_id = split(",",data.aws_ssm_parameter.public_subnet_ids.value)[0]
}