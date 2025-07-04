// modules/rds/main.tf
// Note: The invalid password issue must be fixed in input variables or terraform.tfvars.
// The password must exclude '/', '@', '"', and spaces.
// Example variable declaration enforcing regex:

variable "db_password" {
  description = "RDS master user password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && can(regex("^[^/@\" ]+$", var.db_password))
    error_message = "Password must be at least 8 characters and cannot contain '/', '@', '\"', or spaces."
  }
}

resource "aws_db_instance" "default" {
  identifier         = var.db_identifier
  engine             = var.db_engine
  instance_class     = var.db_instance_class
  allocated_storage  = var.db_allocated_storage
  # name argument removed as it is deprecated
  username           = var.db_username
  password           = var.db_password
  parameter_group_name= var.db_parameter_group_name
  skip_final_snapshot= true

  tags = var.tags
}