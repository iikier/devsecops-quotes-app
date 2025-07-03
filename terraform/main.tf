# ========================================
# TERRAFORM MAIN - ARQUITETURA MODULAR
# ========================================
# Este arquivo orquestra todos os módulos para criar a infraestrutura completa
# PRINCÍPIO DevSecOps: Separação de responsabilidades e reutilização

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend remoto para estado do Terraform (descomente para usar S3)
  # backend "s3" {
  #   bucket = "devsecops-terraform-state"
  #   key    = "infrastructure/terraform.tfstate"
  #   region = "us-east-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region
  
  # Tags padrão aplicadas a TODOS os recursos
  default_tags {
    tags = var.default_tags
  }
}

# ========================================
# MÓDULO DE NETWORKING
# ========================================
# Responsável por: VPC, Subnets, Internet Gateway, Route Tables, Security Groups
module "networking" {
  source = "./modules/networking"
  
  # Variáveis do módulo
  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  admin_cidr      = var.admin_cidr
  
  tags = local.common_tags
}

# ========================================
# MÓDULO DE COMPUTE
# ========================================
# Responsável por: EC2, Key Pairs, User Data, Auto Scaling (futuro)
module "compute" {
  source = "./modules/compute"
  
  # Variáveis do módulo
  project_name                = var.project_name
  environment                = var.environment
  instance_type              = var.instance_type
  ssh_public_key             = var.ssh_public_key
  ssh_private_key_path       = var.ssh_private_key_path
  app_port                   = var.app_port
  enable_detailed_monitoring = var.enable_detailed_monitoring
  
  # Dependências de outros módulos
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  security_group_id   = module.networking.app_security_group_id
  iam_instance_profile = module.ecr.instance_profile_name
  
  tags = local.common_tags
}

# ========================================
# MÓDULO ECR (Container Registry)
# ========================================
# Responsável por: Repositório de imagens Docker e permissões de acesso
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  tags = local.common_tags
}

# ========================================
# MÓDULO DE MONITORING (Futuro)
# ========================================
# Responsável por: CloudWatch, Logs, Alarms, SNS
# module "monitoring" {
#   source = "./modules/monitoring"
#   
#   project_name = var.project_name
#   environment  = var.environment
#   instance_id  = module.compute.instance_id
#   
#   tags = local.common_tags
# }

# ========================================
# LOCALS - Configurações Computadas
# ========================================
locals {
  # Tags comuns aplicadas a todos os recursos
  common_tags = merge(var.default_tags, {
    Environment = var.environment
    Terraform   = "true"
    DeployedAt  = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  })
  
  # Configurações derivadas
  app_name = "${var.project_name}-${var.environment}"
} 