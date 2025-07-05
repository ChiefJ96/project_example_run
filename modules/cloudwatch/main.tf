resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.app_name}-HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80%"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  treat_missing_data = "notBreaching"

  tags = var.tags
}

// Dashboard example
resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 24,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name ]
          ],
          period = 300,
          stat   = "Average",
          region = var.aws_region,
          title  = "${var.app_name} CPU Utilization"
        }
      }
    ]
  })
}
