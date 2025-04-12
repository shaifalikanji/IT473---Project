# 🛠️ WordPress E-Commerce Platform on AWS with Terraform

This capstone project demonstrates how to deploy a **highly available, secure, and scalable WordPress e-commerce platform** on AWS using **Terraform**. The architecture is based on AWS best practices, ensuring fault tolerance, performance, and cost-efficiency.

---

## 📘 Project Details

**Course**: IT473 – Bachelor’s Capstone in Cloud Computing and Solutions  
**University**: Purdue Global  
**Professor**: Steve Savage  
**Group**: Group 4  

**Contributors:**

| Name             | Role                             | Email                                      |
|------------------|----------------------------------|--------------------------------------------|
| Ahmed Bedair     | Cloud Infrastructure Architect   | ahmedbedair@student.purdueglobal.edu       |
| David Mead       | Cloud Developer & Integrator     | davidmead@student.purdueglobal.edu         |
| Willie King      | Project Manager                  | willieking@student.purdueglobal.edu        |
| Shaifali Kanji   | Security & Compliance Engineer   | shaifalikanji@student.purdueglobal.edu     |

---

## 🧱 Project Structure

.
├── provider.tf             # AWS provider configuration
├── backend.tf              # Local backend configuration
├── variables.tf            # Input variables definition
├── terraform.tfvars        # Variable values (excluded from Git)
├── res_network.tf          # VPC, Subnets, IGW, NAT, etc.
├── res_wordpress.tf        # EC2 Auto Scaling, ALB, Launch Template
├── res_iam.tf              # IAM roles for EC2 and other services
├── res_ads.tf              # Active Directory Service / EC2 Domain Join
├── res_monitoring.tf       # CloudWatch, Alarms, Application Insights
├── res_rds.tf              # RDS DB Instance for WordPress
├── res_secrets.tf          # Secrets Manager or SSM Parameter Store
├── user_data_wordpress.sh  # WordPress EC2 setup script
├── .gitignore              # Terraform & secret exclusions
└── README.md               # Project documentation


## ⚙️ Deployment Instructions

### Initialize Terraform
```bash
terraform init

### Review the Plan
```bash
terraform plan

### Apply the Infrastructure
```bash
terraform apply


🌐 Architecture Overview
                    +-------------------+
                    |    Route 53       |
                    +--------+----------+
                             |
                        +----v----+
                        |   ALB   |
                        +----+----+
                             |
                +------------+-----------+
                |                        |
         +------v-----+          +-------v-----+
         |  EC2 (AZ1) |          |  EC2 (AZ2)  |
         +------------+          +-------------+
                |                        |
         +------+----+            +-----+-----+
         |   EFS Mount|           |  EFS Mount|
         +-----------+            +-----------+
                \______________________/
                         |
                 +------------------+
                 |   RDS (Multi-AZ) |
                 +------------------+


🔐 Security Best Practices
✅ Public/Private Subnets separation
✅ NAT Gateways for outbound internet in private subnets
✅ EC2 access restricted to ALB only
✅ Encrypted Amazon RDS (MySQL) with Multi-AZ
✅ IAM roles with least privilege
✅ EFS for shared uploads and stateless EC2
✅ CloudFront, WAF, and Shield (optionally integrated)



📥 Example Variables (terraform.tfvars)

aws_region           = "us-east-1"
aws_access_key       = "AKIAxxxxxxxxxxxxxxxx"   # 🔐 Not recommended to hardcode
aws_secret_key       = "O1aHRZxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # 🔐 Use environment variables or credentials file
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




📚 References
AWS Whitepaper – Best Practices for WordPress on AWS https://docs.aws.amazon.com/whitepapers/latest/best-practices-wordpress/reference-architecture.html
Terraform AWS Provider https://registry.terraform.io/providers/hashicorp/aws/latest/docs


✅ Notes
🔐 Ensure your AWS credentials are securely managed using environment variables, ~/.aws/credentials, or a secrets manager.
📊 Use CloudWatch/X-Ray for monitoring and troubleshooting.
📦 Snapshots, backups, and AMI images should be scheduled via Terraform or AWS Backup.
📦 Future Enhancements
🌐 Integrate CloudFront + WAF for enhanced content delivery and security
🔁 Enable CI/CD pipeline with GitHub Actions or AWS CodePipeline
💾 Add Terraform modules for automated backups and DNS failover


🧩 GitHub Repository
This project is hosted on GitHub:
🔗 https://github.com/shaifalikanji/IT473---Project

🔀 Branches Overview
Branch	Purpose	Status
main	Default branch with stable code	✅ Up to date
enhance	Development branch for new features and improvements	🔄 6 commits ahead, 4 behind main
We follow a feature branching strategy where updates are committed to enhance and later merged into main via pull requests after review and testing.

📌 Note: Always create pull requests from enhance to main for production readiness.
<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.wp_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_dashboard.application_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_dashboard.infrastructure_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.alb_4xx_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_5xx_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.asg_high_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.asg_network_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.asg_network_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_high_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_group_unhealthy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_instance.wordpress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.wordpress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_directory_service_directory.simple_ad](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_directory) | resource |
| [aws_iam_instance_profile.wp_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.rds_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.wp_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.rds_monitoring_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_launch_template.wordpress_lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.wp_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.wp_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.wp_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_secretsmanager_secret.wordpress_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.wordpress_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.allow_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.lb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.wp_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.monitoring_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email_alert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI for WordPress EC2 instances | `string` | `"ami-0655cec52acf2717b"` | no |
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | AWS Access Key ID | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | AWS Secret Access Key | `string` | n/a | yes |
| <a name="input_efs_mount_point"></a> [efs\_mount\_point](#input\_efs\_mount\_point) | Mount point for EFS | `string` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name prefix | `string` | n/a | yes |
| <a name="input_private_azs"></a> [private\_azs](#input\_private\_azs) | Availability zones for private subnets | `list(string)` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDRs for private subnets | `list(string)` | n/a | yes |
| <a name="input_public_azs"></a> [public\_azs](#input\_public\_azs) | Availability zones for public subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDRs for public subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_wp_ami_id"></a> [wp\_ami\_id](#input\_wp\_ami\_id) | AMI ID for WordPress EC2 instances | `string` | n/a | yes |
| <a name="input_wp_instance_type"></a> [wp\_instance\_type](#input\_wp\_instance\_type) | Instance type for WordPress | `string` | `"t3.micro"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_dashboard_url"></a> [application\_dashboard\_url](#output\_application\_dashboard\_url) | Console URL for viewing the Application CloudWatch Dashboard |
| <a name="output_db_password_secret_arn"></a> [db\_password\_secret\_arn](#output\_db\_password\_secret\_arn) | ARN of the Secrets Manager secret storing the database credentials |
| <a name="output_efs_mount_target"></a> [efs\_mount\_target](#output\_efs\_mount\_target) | Mount target for EFS used to persist WordPress content |
| <a name="output_infrastructure_dashboard_url"></a> [infrastructure\_dashboard\_url](#output\_infrastructure\_dashboard\_url) | Console URL for viewing the Infrastructure CloudWatch Dashboard |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | RDS MySQL endpoint used by WordPress |
| <a name="output_sns_alert_topic_arn"></a> [sns\_alert\_topic\_arn](#output\_sns\_alert\_topic\_arn) | SNS topic used for monitoring alerts (CloudWatch) |
| <a name="output_wordpress_asg_name"></a> [wordpress\_asg\_name](#output\_wordpress\_asg\_name) | Name of the Auto Scaling Group for WordPress EC2 instances |
| <a name="output_wordpress_ec2_iam_role"></a> [wordpress\_ec2\_iam\_role](#output\_wordpress\_ec2\_iam\_role) | IAM role attached to WordPress EC2 instances |
| <a name="output_wordpress_url"></a> [wordpress\_url](#output\_wordpress\_url) | Public URL to access the WordPress site |
<!-- END_TF_DOCS -->