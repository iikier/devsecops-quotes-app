#!/bin/bash

# ========================================
# SCRIPT DE CONFIGURAÇÃO DO AMBIENTE LOCAL
# ========================================
# Este script configura o ambiente local para desenvolvimento DevSecOps

set -e

echo "🚀 Configurando ambiente local DevSecOps..."

# ========================================
# VERIFICAÇÕES DE PRÉ-REQUISITOS
# ========================================
echo "🔍 Verificando pré-requisitos..."

# Verificar se o Git está instalado
if ! command -v git &> /dev/null; then
    echo "❌ Git não está instalado. Por favor, instale o Git primeiro."
    exit 1
fi

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não está instalado. Por favor, instale o Node.js primeiro."
    exit 1
fi

echo "✅ Pré-requisitos verificados!"

# ========================================
# CONFIGURAÇÃO DE FERRAMENTAS DEVSECOPS
# ========================================
echo "🛠️ Instalando ferramentas DevSecOps..."

# Instalar Terraform (se não estiver instalado)
if ! command -v terraform &> /dev/null; then
    echo "📦 Instalando Terraform..."
    
    # Para Linux/macOS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install terraform
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install terraform
    else
        echo "⚠️ Por favor, instale o Terraform manualmente: https://terraform.io"
    fi
else
    echo "✅ Terraform já está instalado: $(terraform version | head -n1)"
fi

# Instalar AWS CLI (se não estiver instalado)
if ! command -v aws &> /dev/null; then
    echo "📦 Instalando AWS CLI..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install awscli
    fi
else
    echo "✅ AWS CLI já está instalado: $(aws --version)"
fi

# Instalar ferramentas de segurança
echo "🛡️ Instalando ferramentas de segurança..."

# TruffleHog para detecção de secrets
if ! command -v trufflehog &> /dev/null; then
    echo "📦 Instalando TruffleHog..."
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
fi

# Checkov para IaC scanning
if ! command -v checkov &> /dev/null; then
    echo "📦 Instalando Checkov..."
    pip3 install checkov
fi

# ========================================
# CONFIGURAÇÃO DO PROJETO
# ========================================
echo "⚙️ Configurando projeto..."

# Instalar dependências Node.js
if [ -f "package.json" ]; then
    echo "📦 Instalando dependências Node.js..."
    npm install
else
    echo "⚠️ package.json não encontrado no diretório atual"
fi

# ========================================
# CONFIGURAÇÃO DE CHAVES SSH
# ========================================
echo "🔑 Configurando chaves SSH..."

SSH_KEY_PATH="$HOME/.ssh/devsecops-key"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "🔑 Gerando nova chave SSH para DevSecOps..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "devsecops@$(hostname)"
    echo "✅ Chave SSH criada em: $SSH_KEY_PATH"
    echo "📋 Chave pública:"
    cat "${SSH_KEY_PATH}.pub"
    echo ""
    echo "💡 Copie a chave pública acima para o arquivo terraform.tfvars"
else
    echo "✅ Chave SSH já existe em: $SSH_KEY_PATH"
fi

# ========================================
# CONFIGURAÇÃO DO TERRAFORM
# ========================================
echo "🏗️ Configurando Terraform..."

if [ -d "terraform" ]; then
    cd terraform
    
    # Copiar arquivo de exemplo se não existir
    if [ ! -f "terraform.tfvars" ]; then
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            echo "📋 Arquivo terraform.tfvars criado a partir do exemplo"
            echo "⚠️ IMPORTANTE: Edite o arquivo terraform.tfvars com suas configurações!"
            echo "   - Adicione sua chave SSH pública"
            echo "   - Configure seu IP para admin_cidr (opcional)"
        fi
    fi
    
    cd ..
else
    echo "⚠️ Diretório terraform/ não encontrado"
fi

# ========================================
# CONFIGURAÇÃO DO DOCKER
# ========================================
echo "🐳 Testando Docker..."

# Testar se o Docker funciona
if docker run hello-world > /dev/null 2>&1; then
    echo "✅ Docker está funcionando corretamente"
else
    echo "⚠️ Docker pode precisar de permissões. Tente: sudo usermod -aG docker $USER"
fi

# ========================================
# SCRIPTS ÚTEIS
# ========================================
echo "📝 Criando scripts úteis..."

# Script para executar scans de segurança localmente
cat > scripts/security-scan.sh << 'EOF'
#!/bin/bash
echo "🛡️ Executando scans de segurança locais..."

echo "🔍 1. Scan de secrets com TruffleHog..."
trufflehog filesystem . --json > security-reports/trufflehog.json || echo "TruffleHog scan completed"

echo "🔍 2. Scan de IaC com Checkov..."
checkov -d terraform/ --output json > security-reports/checkov.json || echo "Checkov scan completed"

echo "🔍 3. Audit de dependências npm..."
npm audit --json > security-reports/npm-audit.json || echo "npm audit completed"

echo "🔍 4. Scan de container (se Dockerfile existir)..."
if [ -f "Dockerfile" ]; then
    docker build -t local-security-test .
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image local-security-test --format json > security-reports/trivy.json || echo "Trivy scan completed"
fi

echo "✅ Scans de segurança concluídos! Verifique os relatórios em security-reports/"
EOF

chmod +x scripts/security-scan.sh

# Script para deploy local
cat > scripts/local-deploy.sh << 'EOF'
#!/bin/bash
echo "🚀 Deploy local da aplicação..."

echo "🐳 Construindo imagem Docker..."
docker build -t devsecops-quotes-app:local .

echo "🛑 Parando container anterior (se existir)..."
docker stop devsecops-quotes-app 2>/dev/null || true
docker rm devsecops-quotes-app 2>/dev/null || true

echo "▶️ Iniciando novo container..."
docker run -d \
    --name devsecops-quotes-app \
    -p 3000:3000 \
    devsecops-quotes-app:local

echo "✅ Aplicação rodando em: http://localhost:3000"
echo "📋 Para ver logs: docker logs devsecops-quotes-app"
echo "🛑 Para parar: docker stop devsecops-quotes-app"
EOF

chmod +x scripts/local-deploy.sh

# Criar diretório para relatórios de segurança
mkdir -p security-reports
echo "security-reports/" >> .gitignore

# ========================================
# FINALIZAÇÃO
# ========================================
echo ""
echo "🎉 Configuração do ambiente local concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Configure suas credenciais AWS: aws configure"
echo "2. Edite terraform/terraform.tfvars com suas configurações"
echo "3. Execute: cd terraform && terraform init"
echo "4. Para deploy local: ./scripts/local-deploy.sh"
echo "5. Para scans de segurança: ./scripts/security-scan.sh"
echo ""
echo "🔗 URLs úteis:"
echo "   - Aplicação local: http://localhost:3000"
echo "   - Documentação: terraform/README.md"
echo ""
echo "✅ Ambiente DevSecOps pronto para uso!" 