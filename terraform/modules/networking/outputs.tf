# ========================================
# OUTPUTS DO MÓDULO NETWORKING
# ========================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "app_security_group_id" {
  description = "ID do Security Group da aplicação"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "ID do Security Group do Load Balancer"
  value       = aws_security_group.alb.id
}

output "availability_zones" {
  description = "Availability Zones utilizadas"
  value       = data.aws_availability_zones.available.names
} 