# ========================================
# OUTPUTS DO MÓDULO ECR
# ========================================

output "repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_name" {
  description = "Nome do repositório ECR"
  value       = aws_ecr_repository.app.name
}

output "repository_arn" {
  description = "ARN do repositório ECR"
  value       = aws_ecr_repository.app.arn
}

output "instance_profile_name" {
  description = "Nome do instance profile para EC2 acessar ECR"
  value       = aws_iam_instance_profile.ec2_ecr_access.name
}

output "instance_profile_arn" {
  description = "ARN do instance profile para EC2 acessar ECR"
  value       = aws_iam_instance_profile.ec2_ecr_access.arn
} 