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
