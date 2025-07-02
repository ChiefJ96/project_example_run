variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
  description = "Private subnet IDs for RDS subnet group"
}

variable "security_group_ids" {
  type = list(string)
  description = "Security group IDs to attach to RDS instances"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
}