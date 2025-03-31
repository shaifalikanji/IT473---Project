# CloudWatch Alarm for ASG average CPU utilization
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "ASG-High-CPU"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp_asg.name
  }

  alarm_description = "Average CPU across ASG is above 80%."
}

# CloudWatch Alarm for ALB Target Group Unhealthy Hosts
resource "aws_cloudwatch_metric_alarm" "target_group_unhealthy" {
  alarm_name          = "ALB-Unhealthy-Targets"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    TargetGroup  = aws_lb_target_group.wp_tg.arn_suffix
    LoadBalancer = aws_lb.wp_alb.arn_suffix
  }

  alarm_description = "One or more instances in the ALB target group are unhealthy."
}

resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  alarm_description   = "Alarm if RDS CPU > 80%"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }

  alarm_actions = []  # Add SNS topic if needed
}

