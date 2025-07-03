#!/bin/bash

# ========================================
# USER DATA SCRIPT - INICIALIZAÇÃO EC2
# ========================================
# Este script prepara a instância Ubuntu com todas as ferramentas necessárias
# para o pipeline DevSecOps

set -e  # Sai se qualquer comando falhar

# ========================================
# VARIÁVEIS DO TEMPLATE
# ========================================
project_name="${project_name}"
ENVIRONMENT="${environment}"
APP_PORT="${app_port}"

# ========================================
# LOGGING CONFIGURATION
# ========================================
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "INICIANDO CONFIGURAÇÃO DA INSTÂNCIA"
echo "Project: $project_name"
echo "Environment: $ENVIRONMENT"
echo "App Port: $APP_PORT"
echo "Timestamp: $(date)"
echo "=========================================="

# ========================================
# DESATIVAR FIREWALL LOCAL (UFW)
# ========================================
# Melhor prática na AWS é gerenciar acesso via Security Groups, não firewall local.
echo "🔥 Desativando UFW (firewall local)..."
ufw disable

# ========================================
# SYSTEM UPDATE & BASIC PACKAGES
# ========================================
echo "📦 Atualizando sistema e instalando pacotes básicos..."

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

# Pacotes essenciais para DevSecOps
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    htop \
    tree \
    vim \
    fail2ban \
    ufw \
    awscli

# ========================================
# SECURITY HARDENING
# ========================================
echo "🔒 Aplicando hardening de segurança..."

# Configurar UFW (Uncomplicated Firewall)
ufw allow ssh
ufw allow $APP_PORT
ufw --force enable

# Configurar Fail2Ban para SSH
systemctl enable fail2ban
systemctl start fail2ban

# Configurar automatic security updates
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# ========================================
# DOCKER INSTALLATION
# ========================================
echo "🐳 Instalando Docker..."

# Adicionar repositório oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicionar usuário ubuntu ao grupo docker
usermod -aG docker ubuntu

# Habilitar Docker no boot
systemctl enable docker
systemctl start docker

# ========================================
# NODE.JS INSTALLATION (Via NodeSource)
# ========================================
echo "📦 Instalando Node.js..."

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt-get install -y nodejs

# Verificar instalação
node --version
npm --version

# ========================================
# NGINX INSTALLATION (Para reverse proxy)
# ========================================
echo "🌐 Instalando NGINX..."

apt-get install -y nginx

# Configurar NGINX como reverse proxy para a aplicação
cat > /etc/nginx/sites-available/$project_name << 'EOF'
server {
    listen 80;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Remover site padrão e ativar nosso site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/$project_name /etc/nginx/sites-enabled/

# Testar configuração e reiniciar NGINX
nginx -t
systemctl enable nginx
systemctl restart nginx

# ========================================
# CLOUDWATCH AGENT INSTALLATION
# ========================================
echo "📊 Instalando CloudWatch Agent..."

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Configuração básica do CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/$project_name-$ENVIRONMENT",
                        "log_stream_name": "{instance_id}/user-data.log"
                    },
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/$project_name-$ENVIRONMENT",
                        "log_stream_name": "{instance_id}/nginx-access.log"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/$project_name-$ENVIRONMENT",
                        "log_stream_name": "{instance_id}/nginx-error.log"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "$project_name/$ENVIRONMENT",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# ========================================
# APPLICATION DIRECTORY SETUP
# ========================================
echo "📁 Configurando diretórios da aplicação..."

# Criar diretório para a aplicação
mkdir -p /opt/$project_name
chown ubuntu:ubuntu /opt/$project_name

# Criar script de deploy
cat > /opt/$project_name/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Iniciando deploy da aplicação..."

cd /opt/${project_name}

# Se existe container anterior, pare e remova
if [ $(docker ps -aq -f name=${project_name}) ]; then
    echo "🛑 Parando container anterior..."
    docker stop ${project_name} || true
    docker rm ${project_name} || true
fi

# Build da nova imagem
echo "🔨 Construindo nova imagem..."
docker build -t ${project_name}:latest .

# Executar novo container
echo "▶️ Iniciando novo container..."
docker run -d \
    --name ${project_name} \
    --restart unless-stopped \
    -p 3000:3000 \
    ${project_name}:latest

echo "✅ Deploy concluído!"
docker logs ${project_name}
EOF

chmod +x /opt/$project_name/deploy.sh
chown ubuntu:ubuntu /opt/$project_name/deploy.sh

# ========================================
# SYSTEM SERVICE CONFIGURATION
# ========================================
echo "⚙️ Configurando serviços do sistema..."

# Garantir que todos os serviços essenciais estejam habilitados
systemctl enable docker
systemctl enable nginx
systemctl enable fail2ban
systemctl enable ufw

# ========================================
# FINAL STEPS
# ========================================
echo "🧹 Finalizando configuração..."

# Limpeza de pacotes desnecessários
apt-get autoremove -y
apt-get autoclean

# Atualizar locate database
updatedb

echo "=========================================="
echo "✅ CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!"
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Docker Version: $(docker --version)"
echo "Node.js Version: $(node --version)"
echo "NGINX Status: $(systemctl is-active nginx)"
echo "=========================================="

# Notificar que a inicialização foi concluída
echo "$(date): User data script completed successfully" >> /var/log/user-data.log

# ========================================
# FINALIZANDO
# ========================================
echo "✅ Script user_data.sh concluído com sucesso!"
echo "Aplicação ${project_name} configurada para rodar na porta ${app_port} no ambiente ${environment}"
echo "--------------------------------------------------"

# Fim do script
# Linha final para garantir que o script não tenha problemas de terminação
# Timestamp: $(date)
# Host: $(hostname)
# User: $(whoami)
#
# Detalhes do Projeto:
# Nome: ${project_name}
# Ambiente: ${environment}
# Porta: ${app_port}
#
# Para depurar, verifique os logs em:
# /var/log/cloud-init-output.log
# /var/log/syslog
#
# Para verificar status dos serviços:
# systemctl status docker
# systemctl status node-app.service
# journalctl -u node-app.service -f
#
# Para verificar a aplicação:
# curl http://localhost:${app_port}
#
# FIM DO SCRIPT DE USER DATA
# ======================================== 