# ---------------------------
# ECR Repository
# ---------------------------
resource "aws_ecr_repository" "webapp" {
  name = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ---------------------------
# IAM Role for EC2 -> ECR Access
# ---------------------------
resource "aws_iam_role" "ec2_role" {
  name = "clo835-ec2-ecr-role"
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

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ---------------------------
# Instance Profile
# ---------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "clo835-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "clo835-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "webapp_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = element(data.aws_subnet_ids.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              $(aws ecr get-login --no-include-email --region ${var.aws_region})
              docker run -d -p 30000:80 ${var.image_uri}
              EOF

  tags = {
    Name = "clo835-webapp-instance"
  }
}

# ---------------------------
# Get Latest Amazon Linux 2 AMI
# ---------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
