# ========================================
# OUTPUTS DO MÓDULO COMPUTE
# ========================================

output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN da instância EC2"
  value       = aws_instance.main.arn
}

output "instance_type" {
  description = "Tipo da instância EC2"
  value       = aws_instance.main.instance_type
}

output "public_ip" {
  description = "IP público da instância (Elastic IP)"
  value       = aws_eip.main.public_ip
}

output "private_ip" {
  description = "IP privado da instância"
  value       = aws_instance.main.private_ip
}

output "public_dns" {
  description = "DNS público da instância"
  value       = aws_instance.main.public_dns
}

output "availability_zone" {
  description = "Availability Zone da instância"
  value       = aws_instance.main.availability_zone
}

output "subnet_id" {
  description = "ID da subnet onde a instância está"
  value       = aws_instance.main.subnet_id
}

output "key_pair_name" {
  description = "Nome do key pair usado"
  value       = aws_key_pair.main.key_name
}

output "security_groups" {
  description = "Security Groups associados à instância"
  value       = aws_instance.main.vpc_security_group_ids
}

output "cloudwatch_log_group" {
  description = "Nome do CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.app_logs.name
}

# Output útil para conexão SSH
output "ssh_connection" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_eip.main.public_ip}"
}

# Output útil para monitoramento
output "monitoring_info" {
  description = "Informações de monitoramento"
  value = {
    detailed_monitoring_enabled = aws_instance.main.monitoring
    cloudwatch_log_group       = aws_cloudwatch_log_group.app_logs.name
    log_retention_days         = aws_cloudwatch_log_group.app_logs.retention_in_days
  }
}

# ========================================
# SAÍDAS DE SEGURANÇA E MONITORAMENTO
# ========================================

output "cloudwatch_log_group_name" {
  description = "Nome do log group do CloudWatch para a aplicação"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "ami_id" {
  description = "ID da AMI utilizada para a instância EC2"
  value       = aws_instance.main.ami
} 