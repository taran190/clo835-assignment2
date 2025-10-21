variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ca-central-1"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "clo835-webapp"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "image_uri" {
  description = "Docker image URI to deploy on EC2"
  type        = string
  default     = ""
}
