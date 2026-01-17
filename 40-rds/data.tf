data "aws_ssm_parameter" "mysql_sg" {
    name = "/${var.project_name}/${var.environment}/mysql_sg_id"
}


#subnet name for aws_sb_subnet_group
data "aws_ssm_parameter" "database_subnet_group_name" {
    name = "/${var.project_name}/${var.environment}/database_subnet_group_name"
}
