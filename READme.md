 Architecture Overview

- VPC with public and private subnets across 2 availability zones
- Internet Gateway for public subnet internet outbound access
- Application Load Balancer (ALB) public-facing with security groups
- EC2 instances running in private subnets behind ALB
- RDS MySQL multi-AZ database in private subnets
- S3 Bucket for app data or pipeline artifacts
- IAM Roles for EC2, CodePipeline, and CodeBuild with least privileges
- CloudWatch Log Group for centralized monitoring
- CodePipeline + CodeBuild continuous deployment sourced from GitHub

---

 Prerequisites

- Terraform 1.5 or higher installed locally
- AWS CLI configured or environment variables for AWS credentials
- GitHub personal OAuth token with repo and pipeline permissions
- An existing EC2 Key Pair in the target region
