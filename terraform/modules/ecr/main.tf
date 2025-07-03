# ========================================
# MÓDULO ECR - ELASTIC CONTAINER REGISTRY
# ========================================
# Container registry privado e seguro para as imagens Docker

# ========================================
# ECR REPOSITORY
# ========================================
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"  # Permite override de tags
  
  # SEGURANÇA: Scan automático de vulnerabilidades
  image_scanning_configuration {
    scan_on_push = true
  }
  
  # SEGURANÇA: Criptografia das imagens
  encryption_configuration {
    encryption_type = "AES256"
  }
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecr"
    Type = "Container Registry"
  })
}

# ========================================
# LIFECYCLE POLICY - LIMPEZA AUTOMÁTICA
# ========================================
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 5 development images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ========================================
# IAM ROLE PARA EC2 ACESSAR ECR
# ========================================
resource "aws_iam_role" "ec2_ecr_access" {
  name = "${var.project_name}-${var.environment}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Policy para EC2 fazer pull das imagens
resource "aws_iam_role_policy" "ec2_ecr_access" {
  name = "${var.project_name}-${var.environment}-ecr-access"
  role = aws_iam_role.ec2_ecr_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = aws_ecr_repository.app.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# Instance Profile para EC2
resource "aws_iam_instance_profile" "ec2_ecr_access" {
  name = "${var.project_name}-${var.environment}-ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_access.name

  tags = var.tags
} 