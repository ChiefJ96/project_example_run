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
variable "db_engine" {
  type = string
  description = "The database engine to use for the RDS instance (e.g., mysql, postgres)"
}
variable "db_instance_class" {
  type = string
  description = "The instance class for the RDS instance (e.g., db.t3.micro)"
}
variable "db_allocated_storage" {
  type = number
  description = "The allocated storage size in GB for the RDS instance"
}
variable "db_parameter_group_name" {
  type = string
  description = "The name of the DB parameter group to associate with the RDS instance"
}
variable "db_identifier" {
  type = string
  description = "The identifier for the RDS instance (e.g., my-db-instance)"
}