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

```plaintext
.
├── provider.tf             # AWS provider configuration
├── backend.tf              # lOCAL bACKEND
├── variables.tf            # Input variables definition
├── terraform.tfvars        # Variable values (excluded from Git)
├── res_network.tf          # VPC, Subnets, IGW, NAT, etc.
├── res_wordpress.tf        # EC2 Auto Scaling, ALB, Launch Template
├── res_iam.tf              # IAM roles for EC2 and other services
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

env_name              = "ecom"
aws_region            = "us-east-1"
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
public_azs            = ["us-east-1a", "us-east-1b"]
private_azs           = ["us-east-1a", "us-east-1b"]
wp_ami_id             = "ami-0c55b159cbfafe1f0"
wp_instance_type      = "t3.micro"
efs_mount_point       = "fs-xxxxxx.efs.us-east-1.amazonaws.com"



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