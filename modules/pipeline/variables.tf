variable "region" {
  type = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type = string
}

variable "github_branch" {
  description = "GitHub branch"
  type = string
}

variable "oauth_token" {
  description = "GitHub Oauth Token"
  type = string
  sensitive = true
}

variable "ec2_instance_role" {
  description = "Instance Role name for CodeBuild to use"
  type = string
}

variable "tags" {
  type = map(string)
}
variable "s3_bucket_name" {
  description = "S3 bucket for storing pipeline artifacts"
  type        = string
}
variable "project_name" {
  description = "Project name for the pipeline"
  type        = string
  
}
variable "pipeline_role_arn" {
  description = "ARN of the IAM role for the pipeline"
  type        = string
} 
variable "artifact_bucket" {
  description = "S3 bucket for CodePipeline artifacts"
  type        = string
}
variable "codebuild_project_name" {
  description = "The name of the CodeBuild project to use in the pipeline."
  type        = string
}