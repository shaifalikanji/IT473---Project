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
