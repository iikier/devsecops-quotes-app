# 🪟 **GUIA PARA USUÁRIOS WINDOWS**

Este guia explica como configurar e usar o ambiente DevSecOps no **Windows**.

## 🎯 **OPÇÕES PARA EXECUTAR OS SCRIPTS**

### **1. 💻 PowerShell (RECOMENDADO)**
```powershell
# Executar o script PowerShell nativo
.\scripts\setup-local-env.ps1
```

### **2. 🐧 WSL (Windows Subsystem for Linux)**
```bash
# Instalar WSL (uma vez só)
wsl --install

# Executar script bash no WSL
wsl bash scripts/setup-local-env.sh
```

### **3. 🦄 Git Bash**
```bash
# Se você tem Git instalado, pode usar Git Bash
bash scripts/setup-local-env.sh
```

## 🚀 **SETUP RÁPIDO PARA WINDOWS**

### **1. Pré-requisitos**
Instale estas ferramentas primeiro:

- **🐳 Docker Desktop**: https://www.docker.com/products/docker-desktop
- **📦 Node.js**: https://nodejs.org/
- **🔧 Git**: https://git-scm.com/download/win
- **☁️ AWS CLI**: https://aws.amazon.com/cli/

### **2. Configuração Automática**
```powershell
# Abrir PowerShell como Administrador
# Navegar para o diretório do projeto
cd C:\caminho\para\seu\projeto

# Executar configuração
.\scripts\setup-local-env.ps1
```

### **3. Configuração Manual (se preferir)**
```powershell
# 1. Instalar Chocolatey (gerenciador de pacotes)
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Instalar ferramentas via Chocolatey
choco install terraform awscli -y

# 3. Gerar chave SSH
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\devsecops-key

# 4. Instalar dependências Node.js
npm install

# 5. Configurar Terraform
cd terraform
cp terraform.tfvars.example terraform.tfvars
# (Editar terraform.tfvars com suas configurações)
```

## 🛠️ **SCRIPTS ESPECÍFICOS PARA WINDOWS**

### **📝 Scripts Criados:**
- `scripts/setup-local-env.ps1` - Configuração inicial (PowerShell)
- `scripts/security-scan.ps1` - Scans de segurança (PowerShell)
- `scripts/local-deploy.ps1` - Deploy local (PowerShell)

### **🚀 Como usar:**
```powershell
# Deploy local da aplicação
.\scripts\local-deploy.ps1

# Scans de segurança
.\scripts\security-scan.ps1
```

## 🔧 **CONFIGURAÇÕES ESPECÍFICAS DO WINDOWS**

### **📋 Variáveis de Ambiente**
```powershell
# Definir variáveis de ambiente (opcional)
$env:AWS_REGION = "us-east-1"
$env:PROJECT_NAME = "devsecops-quotes"
```

### **🔑 Localização da Chave SSH**
```
Windows: C:\Users\SeuUsuario\.ssh\devsecops-key
Linux:   ~/.ssh/devsecops-key
```

### **📁 Caminhos no Windows**
```powershell
# Terraform
cd terraform
terraform init

# Docker
docker build -t app .
docker run -p 3000:3000 app

# Aplicação Node.js
node server.js
```

## 🐳 **DOCKER NO WINDOWS**

### **⚙️ Configuração do Docker Desktop:**
1. Instalar Docker Desktop
2. Habilitar WSL2 integration (recomendado)
3. Configurar recursos (CPU/Memory)

### **🧪 Testar Docker:**
```powershell
# Testar instalação
docker run hello-world

# Verificar se está rodando
docker --version
docker ps
```

## ☁️ **AWS CLI NO WINDOWS**

### **⚙️ Configuração:**
```powershell
# Configurar credenciais
aws configure

# Testar configuração
aws sts get-caller-identity
```

### **🔐 Arquivos de configuração:**
```
Localização: C:\Users\SeuUsuario\.aws\
- credentials (suas chaves)
- config (configurações)
```

## 🎯 **COMANDOS ÚTEIS PARA WINDOWS**

### **📋 PowerShell:**
```powershell
# Ver processos Docker
docker ps

# Logs da aplicação
docker logs devsecops-quotes-app

# Conectar na instância AWS (depois do deploy)
ssh -i $env:USERPROFILE\.ssh\devsecops-key ubuntu@IP_PUBLICO
```

### **🔍 Troubleshooting:**
```powershell
# Verificar se as ferramentas estão instaladas
terraform --version
aws --version
docker --version
node --version

# Verificar conectividade AWS
aws ec2 describe-regions --region us-east-1
```

## 🚨 **PROBLEMAS COMUNS NO WINDOWS**

### **1. Permissões do PowerShell**
```powershell
# Se der erro de execução, rode:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### **2. Docker não inicia**
- Verificar se Docker Desktop está rodando
- Verificar se WSL2 está habilitado
- Restart Docker Desktop

### **3. SSH não funciona**
```powershell
# Verificar se SSH está disponível
ssh -V

# Se não estiver, instalar OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Client
```

### **4. Terraform não encontra arquivos**
```powershell
# Usar caminhos completos no Windows
terraform plan -var-file=".\dev.tfvars"
```

## 🎉 **PRÓXIMOS PASSOS**

Após executar o script de configuração:

1. **✅ Configurar AWS**: `aws configure`
2. **📝 Editar terraform.tfvars** com sua chave SSH
3. **🚀 Testar localmente**: `.\scripts\local-deploy.ps1`
4. **☁️ Deploy na AWS**: `cd terraform; terraform init; terraform apply`

---

**💡 Dica**: Use o **Windows Terminal** para uma melhor experiência com PowerShell e múltiplas abas! 