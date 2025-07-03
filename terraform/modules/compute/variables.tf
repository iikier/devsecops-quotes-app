# ========================================
# VARIÁVEIS DO MÓDULO COMPUTE
# ========================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "Chave pública SSH para acesso à instância."
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Caminho local para o arquivo da chave privada SSH."
  type        = string
}

variable "app_port" {
  description = "Porta em que a aplicação Node.js irá rodar."
  type        = number
  default     = 3000
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the instance."
  type        = string
  default     = null
}

# ========================================
# VARIÁVEIS DE NETWORKING (vindas do módulo networking)
# ========================================

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group da aplicação"
  type        = string
}

# ========================================
# CONFIGURAÇÕES OPCIONAIS
# ========================================

variable "root_volume_size" {
  description = "Tamanho do volume root em GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "Volume size deve estar entre 8GB e 100GB."
  }
}

variable "enable_detailed_monitoring" {
  description = "Habilitar monitoramento detalhado do CloudWatch"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 14
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention deve ser um valor válido do CloudWatch."
  }
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
} 