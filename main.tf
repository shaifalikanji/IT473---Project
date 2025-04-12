resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.public_azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.private_azs[count.index]
  tags = {
    Name = "${var.env_name}-private-subnet-${count.index + 1}"
  }
}


#security group
resource "aws_security_group" "allow_ssh" {
  name        = "${var.env_name}-allow-ssh"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-allow-ssh"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env_name}-private-rt"
  }
}
resource "aws_route_table_association" "public_subnets" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnets" {
  for_each       = { for idx, subnet in aws_subnet.private : idx => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}
# SNS Topic for Alerts
resource "aws_sns_topic" "monitoring_alerts" {
  name = "monitoring-alerts-topic"
}

# Email Subscription for Alerts
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = "email"
  endpoint  = "ahmedbedair@student.purdueglobal.edu"
}

# ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_error" {
  alarm_name          = "${var.env_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  dimensions = {
    LoadBalancer = aws_lb.wp_alb.arn_suffix
  }
  alarm_description = "ALB 5xx error rate is too high"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]
}

# ALB 4XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_4xx_error" {
  alarm_name          = "${var.env_name}-alb-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 100
  dimensions = {
    LoadBalancer = aws_lb.wp_alb.arn_suffix
  }
  alarm_description = "ALB 4xx error rate is too high"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]
}

# ASG Average CPU Utilization
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
  alarm_description = "Average CPU across ASG is above 80%"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]
}

# ASG Network In
resource "aws_cloudwatch_metric_alarm" "asg_network_in" {
  alarm_name          = "ASG-Network-In-High"
  namespace           = "AWS/EC2"
  metric_name         = "NetworkIn"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 50000000
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp_asg.name
  }
  alarm_description = "High network IN traffic on ASG"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]
}

# ASG Network Out
resource "aws_cloudwatch_metric_alarm" "asg_network_out" {
  alarm_name          = "ASG-Network-Out-High"
  namespace           = "AWS/EC2"
  metric_name         = "NetworkOut"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 50000000
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp_asg.name
  }
  alarm_description = "High network OUT traffic on ASG"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]
}

# ALB Unhealthy Host Count
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
    TargetGroup  = aws_lb_target_group.wp_tg.arn_suffix,
    LoadBalancer = aws_lb.wp_alb.arn_suffix
  }
  alarm_description = "One or more targets in ALB are unhealthy"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]
}

# IAM Role for RDS Enhanced Monitoring
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

# RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU usage above 80%"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }
  alarm_actions = [aws_sns_topic.monitoring_alerts.arn]
}
# Infrastructure Dashboard
resource "aws_cloudwatch_dashboard" "infrastructure_dashboard" {
  dashboard_name = "${var.env_name}-infra-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0, y = 0, width = 6, height = 6,
        properties = {
          title = "ASG Average CPU",
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.wp_asg.name]
          ],
          period = 300,
          stat = "Average",
          region = "us-east-1"
        }
      },
      {
        type = "metric",
        x = 6, y = 0, width = 6, height = 6,
        properties = {
          title = "RDS CPU",
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.wordpress.id]
          ],
          period = 300,
          stat = "Average",
          region = "us-east-1"
        }
      },
      {
        type = "metric",
        x = 0, y = 6, width = 6, height = 6,
        properties = {
          title = "ALB Request Count",
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.wp_alb.arn_suffix]
          ],
          period = 300,
          stat = "Sum",
          region = "us-east-1"
        }
      },
      {
        type = "metric",
        x = 6, y = 6, width = 6, height = 6,
        properties = {
          title = "ALB Network In/Out",
          metrics = [
            ["AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", aws_lb.wp_alb.arn_suffix]
          ],
          period = 300,
          stat = "Sum",
          region = "us-east-1"
        }
      }
    ]
  })
}

# Application Dashboard
resource "aws_cloudwatch_dashboard" "application_dashboard" {
  dashboard_name = "${var.env_name}-app-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0, y = 0, width = 6, height = 6,
        properties = {
          title = "ALB 5XX Errors",
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", aws_lb.wp_alb.arn_suffix]
          ],
          period = 300,
          stat = "Sum",
          region = "us-east-1"
        }
      },
      {
        type = "metric",
        x = 6, y = 0, width = 6, height = 6,
        properties = {
          title = "ALB 4XX Errors",
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", aws_lb.wp_alb.arn_suffix]
          ],
          period = 300,
          stat = "Sum",
          region = "us-east-1"
        }
      },
      {
        type = "metric",
        x = 0, y = 6, width = 6, height = 6,
        properties = {
          title = "Unhealthy Hosts",
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", aws_lb_target_group.wp_tg.arn_suffix, "LoadBalancer", aws_lb.wp_alb.arn_suffix]
          ],
          period = 300,
          stat = "Average",
          region = "us-east-1"
        }
      }
    ]
  })
}
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|;:,.<>?~" # Excludes '/', '@', '"', and space

}

resource "aws_secretsmanager_secret" "wordpress_db" {
  name = "wordpress-db-secret"
}

resource "aws_secretsmanager_secret_version" "wordpress_db" {
  secret_id = aws_secretsmanager_secret.wordpress_db.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
  })
}
resource "aws_iam_role" "wp_ec2_role" {
  name = "${var.env_name}-wp-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "wp_profile" {
  name = "${var.env_name}-wp-instance-profile"
  role = aws_iam_role.wp_ec2_role.name
}
# Launch Template
resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "${var.env_name}-wp-lt"
  image_id      = var.ami_id
  instance_type = var.wp_instance_type

  user_data = base64encode(templatefile("${path.module}/user_data_wordpress.sh", {
    efs_mount_point = var.efs_mount_point,
    db_password     = random_password.db_password.result,
    db_host         = aws_db_instance.wordpress.address
  }))

  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.wp_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "wp_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [for subnet in aws_subnet.public : subnet.id]
  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.wp_tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "${var.env_name}-wordpress"
    propagate_at_launch = true
  }
}

# Load Balancer
resource "aws_lb" "wp_alb" {
  name               = "${var.env_name}-wp-alb"
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "wp_tg" {
  name     = "${var.env_name}-wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener" "wp_listener" {
  load_balancer_arn = aws_lb.wp_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_tg.arn
  }
}
resource "aws_security_group" "wp_sg" {
  name        = "${var.env_name}-wp-sg"
  description = "Security group for WordPress EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH from anywhere (TEMP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-wp-sg"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.env_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-alb-sg"
  }
}
resource "aws_db_subnet_group" "wordpress" {
  name = "wordpress-db-subnet-group"
  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  tags = {
    Name = "WordPress DB Subnet Group"
  }
}

resource "aws_db_instance" "wordpress" {
  identifier             = "wp-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  username = "admin"
  password = random_password.db_password.result
  db_name  = "wordpress"
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.env_name}-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wp_sg.id] # Assuming EC2 uses wp_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-rds-sg"
  }
}
resource "aws_directory_service_directory" "simple_ad" {
  name     = "example.com"
  password = random_password.db_password.result
  size     = "Small"
  type     = "SimpleAD"
  vpc_settings {
    vpc_id = aws_vpc.main.id
    subnet_ids = [
      aws_subnet.private[0].id,
      aws_subnet.private[1].id
    ]
  }
}