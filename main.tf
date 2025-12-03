terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group for web server
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg-iac-demo"
  description = "Security group for IaC demo web server"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere (for demo purposes only!)
  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "WebServer-SG-IaC-Demo"
    Environment = "Demo"
    ManagedBy   = "Terraform"
  }
}

# EC2 Instance for web server
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y

              # Install Apache
              yum install -y httpd

              # Start Apache
              systemctl start httpd
              systemctl enable httpd

              # Create a simple web page
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Infrastructure as Code Demo</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          max-width: 800px;
                          margin: 50px auto;
                          padding: 20px;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          color: white;
                      }
                      .container {
                          background: rgba(255, 255, 255, 0.1);
                          padding: 40px;
                          border-radius: 10px;
                          backdrop-filter: blur(10px);
                      }
                      h1 { margin-top: 0; }
                      .info {
                          background: rgba(255, 255, 255, 0.2);
                          padding: 15px;
                          border-radius: 5px;
                          margin: 20px 0;
                      }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>Infrastructure as Code Demo</h1>
                      <h2>Deployed with Terraform!</h2>
                      <div class="info">
                          <p><strong>What you're seeing:</strong></p>
                          <ul>
                              <li>EC2 instance created automatically</li>
                              <li>Security group configured</li>
                              <li>Apache web server installed</li>
                              <li>All from code, no clicking!</li>
                          </ul>
                      </div>
                      <p><em>This entire infrastructure was deployed in under 2 minutes.</em></p>
                  </div>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name        = "terraform-iac-demo"
    Environment = "in-class"
    ManagedBy   = "Terraform"
  }
}