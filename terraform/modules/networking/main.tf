# ========================================
# MÓDULO NETWORKING - RECURSOS DE REDE
# ========================================
# Responsável por toda a infraestrutura de rede: VPC, Subnets, Security Groups, etc.

# ========================================
# DATA SOURCES
# ========================================

# Busca as Availability Zones disponíveis na região
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# ========================================
# VPC - VIRTUAL PRIVATE CLOUD
# ========================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
    Type = "VPC"
  })
}

# ========================================
# INTERNET GATEWAY
# ========================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-igw"
    Type = "Internet Gateway"
  })
}

# ========================================
# SUBNETS PÚBLICAS
# ========================================

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Type = "Public Subnet"
    Tier = "Public"
    AZ   = data.aws_availability_zones.available.names[count.index]
  })
}

# ========================================
# SUBNETS PRIVADAS
# ========================================

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Type = "Private Subnet"
    Tier = "Private"
    AZ   = data.aws_availability_zones.available.names[count.index]
  })
}

# ========================================
# ROUTE TABLE - PÚBLICO
# ========================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
    Type = "Route Table"
    Tier = "Public"
  })
}

# ========================================
# ROUTE TABLE ASSOCIATIONS - PÚBLICO
# ========================================

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ========================================
# SECURITY GROUP - APLICAÇÃO
# ========================================

resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  description = "Security group para aplicacao ${var.project_name}"
  vpc_id      = aws_vpc.main.id

  # SSH - Apenas para administração
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    
    # SEGURANÇA: Restringe SSH apenas para IPs autorizados
  }

  # HTTP - Para Load Balancer (futuro)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS - Para SSL (futuro)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Aplicação Node.js - Temporário para desenvolvimento
  ingress {
    description = "NodeJS Application"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tráfego de saída - Necessário para updates e downloads
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-sg"
    Type = "Security Group"
    Purpose = "Application"
  })
}

# ========================================
# SECURITY GROUP - LOAD BALANCER (Futuro)
# ========================================

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group para Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # HTTP público
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS público
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tráfego para as instâncias da aplicação
  egress {
    description     = "To Application Instances"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
    Type = "Security Group"
    Purpose = "Load Balancer"
  })
} 