// main.tf
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"

  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                = var.tags
  region              = var.region
}

module "ec2" {
  source = "./modules/ec2"

  ec2_security_group_id  = module.network.ec2_security_group_id
  alb_security_group_id  = module.network.alb_security_group_id
  vpc_id                = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  tags                  = var.tags
  region                = var.region
  ami_id                = var.ec2_ami_id
  instance_type         = var.ec2_instance_type
}

module "rds" {
  source = "./modules/rds"

  security_group_ids = [module.network.rds_security_group_id]
  region            = var.region
  vpc_id            = module.network.vpc_id
  tags              = var.tags
  subnet_ids        = module.network.private_subnet_ids
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
  region      = var.region
  tags        = var.tags
}

module "iam" {
  source = "./modules/iam"

  region = var.region

  tags   = var.tags
}

module "monitoring" {
  source = "./modules/monitoring"
  region = var.region

  tags = var.tags
}

module "pipeline" {
  source = "./modules/pipeline"
 s3_bucket_name      = var.s3_bucket_name

  region              = var.region
  github_owner        = var.github_owner
  github_repo         = var.github_repo
  github_branch       = var.github_branch
  oauth_token         = var.github_oauth_token
  ec2_instance_role   = module.iam.ec2_role_name

  tags                = var.tags
}

// variables.tf
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "tags" {
  type = map(string)
  default = {
    "Environment" = "production"
    "Terraform"   = "true"
    "Project"     = "multi-tier-webapp"
  }
}

variable "project_name" {
  description = "Project name for RDS module"
  type        = string
  default     = "multi-tier-webapp"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c02fb55956c7d316" // Amazon Linux 2 AMI us-east-1 (can be updated)
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro" // cost effective, eligible for free tier if in account
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "appdb"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for app data or pipeline artifacts"
  type        = string
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
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "github_oauth_token" {
  description = "OAuth token with repo and pipeline permissions"
  type        = string
  sensitive   = true
}

// outputs.tf
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "codepipeline_name" {
  value = module.pipeline.codepipeline_name
}