provider "aws" {
  region = var.aws_region
}

# Generate a secure SSH key pair automatically
resource "tls_private_key" "picoclaw_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key with AWS
resource "aws_key_pair" "picoclaw_keypair" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.picoclaw_key.public_key_openssh
}

# Save the private key locally for the user to SSH in with
resource "local_file" "private_key" {
  content         = tls_private_key.picoclaw_key.private_key_pem
  filename        = "${path.module}/${aws_key_pair.picoclaw_keypair.key_name}.pem"
  file_permission = "0400"
}

# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security group allowing SSH, HTTP, and HTTPS traffic
resource "aws_security_group" "picoclaw_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Picoclaw EC2 instance"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting to your IP in production
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "${var.project_name}-sg"
  }
}

locals {
  selected_ami    = var.os_type == "ubuntu" ? data.aws_ami.ubuntu_2204.id : data.aws_ami.amazon_linux_2023.id
  userdata_script = var.os_type == "ubuntu" ? file("${path.module}/../ec2-userdata-ubuntu.sh") : file("${path.module}/../ec2-userdata-al2023.sh")
}

# IAM Role for FinOps Copilot
resource "aws_iam_role" "picoclaw_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "picoclaw_policy" {
  name        = "${var.project_name}-policy"
  description = "IAM policy for FinOps operations"
  policy      = file("${path.module}/../iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "picoclaw_policy_attach" {
  role       = aws_iam_role.picoclaw_role.name
  policy_arn = aws_iam_policy.picoclaw_policy.arn
}

resource "aws_iam_instance_profile" "picoclaw_profile" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.picoclaw_role.name
}

# Launch the EC2 instance
resource "aws_instance" "picoclaw" {
  ami           = local.selected_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.picoclaw_keypair.key_name

  vpc_security_group_ids = [aws_security_group.picoclaw_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.picoclaw_profile.name

  # Inject the userdata script to setup the environment on boot
  user_data = local.userdata_script

  tags = {
    Name = "${var.project_name}-server"
  }
}
