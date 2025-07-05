resource "aws_ssm_parameter" "env_parameters" {
  for_each = var.env_map

  name  = "${var.path_prefix}/${each.key}"
  type  = "SecureString"
  value = each.value
  tags  = var.tags
}
