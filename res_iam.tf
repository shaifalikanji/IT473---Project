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
