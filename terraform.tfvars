# aws_access_key       = "AKIAxxxxxxxxxxxxxxxx"   # 🔐 Not recommended to hardcode
# aws_secret_key       = "O1aHRZxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # 🔐 Use environment variables or credentials file


aws_region           = "us-east-1"
env_name             = "it473-cape-prj-g4"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
public_azs           = ["us-east-1a", "us-east-1b"]
private_azs          = ["us-east-1a", "us-east-1b"]
wp_ami_id            = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2
wp_instance_type     = "t3.micro"
efs_mount_point      = "fs-12345678.efs.us-east-1.amazonaws.com"
public_subnet_ids    = ["subnet-abc123", "subnet-def456"]
