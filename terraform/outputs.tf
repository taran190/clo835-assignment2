output "ecr_repository_url" {
  value = aws_ecr_repository.webapp.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.webapp_instance.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.webapp_instance.id
}
