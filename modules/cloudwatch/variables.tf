variable "app_name" {
  description = "App name for naming resources"
  type        = string
}

variable "asg_name" {
  description = "ASG name for metrics"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags map"
  type        = map(string)
}
