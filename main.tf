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
# }module "pipeline" {
#   source                = "./modules/pipeline"
#   codebuild_project_name = "app-build-project"
#   project_name           = "my-app"
#   pipeline_role_arn      = aws_iam_role.codepipeline_role.arn
#   artifact_bucket        = aws_s3_bucket.artifacts.bucket
#   # ...other required variables...
}
module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
  region      = var.region
  tags        = var.tags
}
module "iam" {
  source        = "./modules/iam"
  project_name  = var.project_name
  region        = var.region
  tags          = var.tags
}
module "pipeline" {
  source = "./modules/pipeline"

  pipeline_role_arn      = module.iam.codepipeline_role_arn
  artifact_bucket        = module.s3.artifact_bucket_name
  codebuild_project_name = "app-build-project"
  s3_bucket_name         = var.s3_bucket_name
  ec2_instance_role      = module.iam.ec2_instance_role_name
  github_repo            = var.github_repo
  tags                   = var.tags
  github_owner           = var.github_owner
  github_branch          = var.github_branch
  project_name           = var.project_name
  region                 = var.region
  oauth_token            = var.github_oauth_token
}

# module "pipeline" {
#   source                = "./modules/pipeline"
#   ec2_instance_role     = module.iam.ec2_instance_role_name
#   tags                  = var.tags
#   s3_bucket_name        = var.s3_bucket_name
#   github_owner          = var.github_owner
#   github_repo           = var.github_repo
#   github_branch         = var.github_branch
#   oauth_token           = var.github_oauth_token
#   region                = var.region
#   codebuild_project_name = "app-build-project"
#   project_name           = var.project_name
#   pipeline_role_arn      = aws_iam_role.codepipeline_role.arn
#   artifact_bucket        = aws_s3_bucket.artifacts.bucket
# }

module "monitoring" {
  source = "./modules/monitoring"
  region = var.region

  tags = var.tags
}

variable "project_name" {
  description = "Project name for IAM resources"
  type        = string
}

variable "github_oauth_token" {
  description = "GitHub OAuth token for pipeline integration"
  type        = string
  sensitive   = true
}

module "rds" {
  source                = "./modules/rds"

  db_identifier          = var.db_identifier
  db_engine              = var.db_engine
  db_instance_class      = var.db_instance_class
  db_allocated_storage   = var.db_allocated_storage
  db_parameter_group_name= var.db_parameter_group_name
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  region                 = var.region
  security_group_ids     = [module.network.rds_security_group_id]
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.private_subnet_ids
  tags                   = var.tags
}