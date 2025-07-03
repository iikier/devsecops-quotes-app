# ========================================
# MÓDULO COMPUTE - RECURSOS DE COMPUTAÇÃO
# ========================================
# Responsável por: EC2 Instances, Key Pairs, User Data, EIP, etc.

# ========================================
# KEY PAIR PARA ACESSO SSH
# ========================================

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = var.ssh_public_key

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-keypair"
    Type = "SSH Key Pair"
  })
}

# ========================================
# TEMPLATE PARA USER DATA
# ========================================

# Template do script de inicialização da instância
locals {
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
    app_port     = var.app_port
  }))
}

# ========================================
# INSTÂNCIA EC2 PRINCIPAL
# ========================================

resource "aws_instance" "main" {
  ami           = "ami-0a7d80731ae1b2435" # AMI Ubuntu 22.04 LTS (us-east-1) - ID VALIDADO
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name # Chave SSH re-habilitada
  subnet_id     = var.public_subnet_ids[0] # Primeira subnet pública
  vpc_security_group_ids = [var.security_group_id]

  # SEGURANÇA: Habilitamos monitoramento detalhado
  monitoring = var.enable_detailed_monitoring

  # SEGURANÇA: Configuração do disco com criptografia
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
    
    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment}-root-volume"
      Type = "EBS Volume"
    })
  }

  # SEGURANÇA: Desabilitamos metadados IMDSv1 (força uso de IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Força IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Script de inicialização
  user_data = local.user_data

  # SEGURANÇA: Configuração de perfil IAM (se necessário)
  iam_instance_profile = var.iam_instance_profile

  tags = merge(var.tags, {
    Name         = "${var.project_name}-${var.environment}-instance"
    Type         = "EC2 Instance"
    Role         = "Application Server"
    OS           = "Ubuntu 22.04 LTS"
    AutoStart    = "true"
    BackupPolicy = "daily"
  })

  # Proteção contra terminação acidental em produção
  disable_api_termination = var.environment == "prod" ? true : false

  lifecycle {
    # Previne destruição acidental da instância
    prevent_destroy = false # Mude para true em produção
    
    # Força nova instância se a AMI mudar
    create_before_destroy = true
  }
}

# ========================================
# ELASTIC IP
# ========================================

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-eip"
    Type = "Elastic IP"
  })

  # Assegura que o Internet Gateway existe antes de criar o EIP
  depends_on = [aws_instance.main]
}

# ========================================
# CLOUDWATCH LOG GROUP (Para logs da aplicação)
# ========================================

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-logs"
    Type = "CloudWatch Log Group"
  })
} 