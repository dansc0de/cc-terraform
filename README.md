# Terraform IaC Demo

This demo creates a simple web server infrastructure on AWS using Terraform.

## What Gets Created

- 1 EC2 t2.micro instance (Amazon Linux 2)
- 1 Security Group (allows HTTP port 80 and SSH port 22)
- Apache web server with a custom page

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform installed (v1.0+)
3. An EC2 Key Pair created in AWS

## Setup Instructions

### 1. Find Your AMI ID
```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Description]' \
  --region us-east-1
```

### 2. Create or Find Your Key Pair
```bash
# List existing key pairs
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName'

# Or create a new one
aws ec2 create-key-pair \
  --key-name iac-demo-key \
  --query 'KeyMaterial' \
  --output text > iac-demo-key.pem
chmod 400 iac-demo-key.pem
```

### 3. Update terraform.tfvars

Edit `terraform.tfvars` and update:
- `key_name` - your EC2 key pair name
- `ami_id` - AMI ID from step 1

### 4. Deploy
```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# Get the website URL
terraform output website_url
```

### 5. Test

Open the URL from the output in your browser.

### 6. Clean Up
```bash
terraform destroy
```

## Cost

This demo uses:
- 1 x t2.micro instance (free tier eligible)
- Minimal data transfer

**Estimated cost:** $0.00/hour if within free tier, ~$0.012/hour otherwise

## Creating ssh key

```shell
aws ec2 create-key-pair \
  --key-name iac-demo-key \
  --query 'KeyMaterial' \
  --output text > iac-demo-key.pem
```

# View AMIs
```shell

```

