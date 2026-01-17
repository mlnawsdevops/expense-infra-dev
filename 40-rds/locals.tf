locals {
    db_name = "${var.project_name}-${var.environment}" #expense-dev
    mysql_sg_id = data.aws_ssm_parameter.mysql_sg.value
    database_subnet_group_name = data.aws_ssm_parameter.database_subnet_group_name.value
}