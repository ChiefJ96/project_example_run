# Output the name of the EC2 IAM role
output "ec2_instance_role_name" {
  description = "Name of the IAM role assigned to EC2 instances"
  value       = aws_iam_role.ec2_instance_role.name
}

# Output the name of the EC2 Instance Profile (used when launching EC2)
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

# Output the name of the CodePipeline IAM role (optional, but useful for linking)
output "codepipeline_role_name" {
  description = "Name of the IAM role used by AWS CodePipeline"
  value       = aws_iam_role.codepipeline_role.name
}
output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}
