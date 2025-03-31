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

# data "aws_secretsmanager_secret" "wordpress_db" {
#   name = "wordpress-db-secret"
# }

# data "aws_secretsmanager_secret_version" "wordpress_db" {
#   secret_id = data.aws_secretsmanager_secret.wordpress_db.id
# }
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
