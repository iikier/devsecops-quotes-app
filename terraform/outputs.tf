# ========================================
# SAÍDAS GLOBAIS (ROOT OUTPUTS)
# ========================================
# Estas são as informações mais importantes que você precisará após a implantação.

output "application_public_ip" {
  description = "IP Público da instância EC2 onde a aplicação está rodando. Use este IP para acessar a aplicação no navegador."
  value       = module.compute.public_ip
}

output "ssh_connection_command" {
  description = "Comando completo para conectar-se à instância via SSH. Copie e cole no seu terminal."
  value       = module.compute.ssh_connection
}

output "ec2_instance_id" {
  description = "O ID da instância EC2 principal."
  value       = module.compute.instance_id
}

output "vpc_id" {
  description = "O ID da VPC onde os recursos foram criados."
  value       = module.networking.vpc_id
} 