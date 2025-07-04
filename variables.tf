
 variable "region" {
  description = "AWS region for resources"
   type        = string
   default     = "us-east-1"
 }


variable "ec2_instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}


variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "The RDS instance identifier"
  type        = string
  default     = "my-db-instance"
}

variable "db_engine" {
  description = "The database engine, e.g. mysql, postgres"
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "The instance type for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage size in GB"
  type        = number
  default     = 20
}

variable "db_parameter_group_name" {
  description = "The DB parameter group name"
  type        = string
  default     = "default.mysql8.0"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for DB"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 8 && can(regex("^[^/@\" ]+$", var.db_password))
    error_message = "Password must be at least 8 characters and cannot contain '/', '@', '\"', or spaces."
  }
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}

variable "s3_bucket_name" {
  description = "S3 bucket for CodePipeline artifacts"
  type        = string
}
variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}
variable "aws_iam_role_name" {
  description = "IAM role name for EC2 instances"
  type        = string
  default     = "ec2-instance-role"
  
}
