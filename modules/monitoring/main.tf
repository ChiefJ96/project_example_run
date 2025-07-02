resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/multi-tier-webapp/app"

  retention_in_days = 30

  tags = var.tags
}