resource "aws_ssm_parameter" "alb" {
    name = "/${var.project_name}/${var.environment}/app_alb_listener_arn"
    type = "String"
    value = aws_lb_listener.http.arn
}