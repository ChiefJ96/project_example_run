// modules/autoscaling/main.tf
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.app_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  network_interfaces {
    security_groups = var.security_group_ids
    associate_public_ip_address = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    env_params_ssm_path = var.env_params_ssm_path
  }))

  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = var.app_name
    propagate_at_launch = true
  }
}

# // variables.tf snippet for autoscaling module
# variable "ami_id" {
#   description = "AMI ID for the launch template"
#   type        = string
# }

# variable "instance_type" {
#   description = "EC2 instance type"
#   type        = string
# }

# variable "key_name" {
#   description = "EC2 Key pair name"
#   type        = string
# }

# variable "security_group_ids" {
#   description = "List of security group IDs"
#   type        = list(string)
# }

# variable "subnet_ids" {
#   description = "List of subnet IDs"
#   type        = list(string)
# }

# variable "target_group_arns" {
#   description = "Load balancer target group ARNs"
#   type        = list(string)
# }

# variable "app_name" {
#   description = "Application name"
#   type        = string
# }

# variable "desired_capacity" {
#   description = "ASG desired capacity"
#   type        = number
#   default     = 2
# }

# variable "max_size" {
#   description = "ASG max size"
#   type        = number
#   default     = 4
# }

# variable "min_size" {
#   description = "ASG min size"
#   type        = number
#   default     = 1
# }

# variable "env_params_ssm_path" {
#   description = "SSM Parameter Store path prefix for env variables"
#   type        = string
# }

# variable "tags" {
#   description = "Tags map"
#   type        = map(string)
# }


# // modules/acm/main.tf
# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = var.tags
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }

#   zone_id = var.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 60
# }

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }

# // variables.tf snippet for ACM module
# variable "domain_name" {
#   description = "Domain name for ACM cert"
#   type        = string
# }

# variable "zone_id" {
#   description = "Route53 hosted zone ID"
#   type        = string
# }

# variable "tags" {
#   description = "Tags map"
#   type        = map(string)
# }

# //--------------------------------------//

# // modules/ssm-parameters/main.tf
# resource "aws_ssm_parameter" "env_parameters" {
#   for_each = var.env_map

#   name  = "${var.path_prefix}/${each.key}"
#   type  = "SecureString"
#   value = each.value
#   tags  = var.tags
# }

# // variables.tf snippet for SSM module
# variable "env_map" {
#   description = "Map of env parameters to store in SSM"
#   type        = map(string)
# }

# variable "path_prefix" {
#   description = "Parameter store path prefix e.g. /myapp/dev"
#   type        = string
# }

# variable "tags" {
#   description = "Tags map"
#   type        = map(string)
# }

//--------------------------------------//

// modules/cloudwatch/main.tf

# // Alarm example: CPU Utilization > 80% for 5 minutes
# resource "aws_cloudwatch_metric_alarm" "high_cpu" {
#   alarm_name          = "${var.app_name}-HighCPU"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 3
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 80
#   alarm_description   = "Alarm when CPU exceeds 80%"
#   dimensions = {
#     AutoScalingGroupName = var.asg_name
#   }
#   treat_missing_data = "notBreaching"

#   tags = var.tags
# }

# // Dashboard example
# resource "aws_cloudwatch_dashboard" "dashboard" {
#   dashboard_name = "${var.app_name}-dashboard"

#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type = "metric",
#         x = 0,
#         y = 0,
#         width = 24,
#         height = 6,
#         properties = {
#           metrics = [
#             [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name ]
#           ],
#           period = 300,
#           stat   = "Average",
#           region = var.aws_region,
#           title  = "${var.app_name} CPU Utilization"
#         }
#       }
#     ]
#   })
# }

# // variables.tf snippet for CloudWatch module
# variable "app_name" {
#   description = "App name for naming resources"
#   type        = string
# }

# variable "asg_name" {
#   description = "ASG name for metrics"
#   type        = string
# }

# variable "aws_region" {
#   description = "AWS region"
#   type        = string
# }

# variable "tags" {
#   description = "Tags map"
#   type        = map(string)
# }

//--------------------------------------//

# // modules/route53/main.tf

# resource "aws_route53_record" "app_alias" {
#   zone_id = var.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = var.alb_dns_name
#     zone_id                = var.alb_zone_id
#     evaluate_target_health = true
#   }
# }

# // variables.tf snippet for Route53 module
# variable "zone_id" {
#   description = "Route53 hosted zone ID"
#   type        = string
# }

# variable "domain_name" {
#   description = "Domain name (e.g. www.example.com)"
#   type        = string
# }

# variable "alb_dns_name" {
#   description = "DNS name of the Application Load Balancer"
#   type        = string
# }

# variable "alb_zone_id" {
#   description = "Zone ID of the Application Load Balancer"
#   type        = string
# }