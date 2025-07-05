variable "ami_id" {
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Load balancer target group ARNs"
  type        = list(string)
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "ASG max size"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "ASG min size"
  type        = number
  default     = 1
}

variable "env_params_ssm_path" {
  description = "SSM Parameter Store path prefix for env variables"
  type        = string
}

variable "tags" {
  description = "Tags map"
  type        = map(string)
}