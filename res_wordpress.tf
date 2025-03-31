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
