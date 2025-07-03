# 🏗️ Infraestrutura DevSecOps com Terraform

Esta é a infraestrutura **moderna e modular** para nossa aplicação DevSecOps, construída seguindo as **melhores práticas** de segurança e escalabilidade.

## 📋 Arquitetura

### 🏗️ **Estrutura Modular**
```
terraform/
├── main.tf                    # Orquestração principal
├── variables.tf               # Variáveis globais
├── outputs.tf                 # Outputs principais
├── terraform.tfvars.example   # Exemplo de configuração
└── modules/
    ├── networking/             # Módulo de rede (VPC, Subnets, SG)
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/                # Módulo de computação (EC2, EIP)
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── scripts/
            └── user_data.sh    # Script de inicialização
```

### 🌐 **Componentes da Infraestrutura**

#### **Módulo Networking**
- ✅ **VPC** personalizada com DNS habilitado
- ✅ **Subnets Públicas** em múltiplas AZs (Alta Disponibilidade)
- ✅ **Subnets Privadas** para recursos futuros
- ✅ **Internet Gateway** para conectividade
- ✅ **Route Tables** configuradas corretamente
- ✅ **Security Groups** seguindo princípio do menor privilégio

#### **Módulo Compute**
- ✅ **EC2 Ubuntu 22.04 LTS** com hardening de segurança
- ✅ **Elastic IP** para IP público fixo
- ✅ **Key Pair** para acesso SSH seguro
- ✅ **EBS Encryption** para proteção de dados
- ✅ **CloudWatch Logs** para observabilidade
- ✅ **User Data** automatizado com todas as ferramentas

## 🚀 Como Usar

### **1. Pré-requisitos**

```bash
# Instalar Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Configurar AWS CLI
aws configure
```

### **2. Configuração**

```bash
# Clonar e navegar para o diretório
cd terraform/

# Copiar arquivo de exemplo e configurar
cp terraform.tfvars.example terraform.tfvars

# Gerar chave SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/devsecops-key

# Editar terraform.tfvars com suas configurações
vim terraform.tfvars
```

### **3. Deploy**

```bash
# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Planejar deployment
terraform plan

# Aplicar infraestrutura
terraform apply
```

### **4. Acessar Aplicação**

```bash
# SSH para a instância
ssh -i ~/.ssh/devsecops-key ubuntu@$(terraform output -raw compute_info | jq -r '.public_ip')

# URL da aplicação
echo "http://$(terraform output -raw compute_info | jq -r '.public_ip'):3000"
```

## 🔒 Características de Segurança

### **🛡️ Hardening Aplicado**
- ✅ **EBS Encryption** - Discos criptografados
- ✅ **IMDSv2** obrigatório - Metadados seguros
- ✅ **Security Groups** restritivos
- ✅ **Fail2Ban** para proteção SSH
- ✅ **UFW Firewall** configurado
- ✅ **Automatic Security Updates**
- ✅ **NGINX Security Headers**

### **📊 Observabilidade**
- ✅ **CloudWatch Logs** centralizados
- ✅ **CloudWatch Metrics** customizadas
- ✅ **Detailed Monitoring** habilitado
- ✅ **Application Logs** estruturados

### **🏗️ Arquitetura Preparada para Produção**
- ✅ **Multi-AZ** para alta disponibilidade
- ✅ **Load Balancer** ready (comentado)
- ✅ **Auto Scaling** ready (futuro)
- ✅ **Monitoring** integrado

## 📦 Ferramentas Pré-instaladas

A instância EC2 vem com todas as ferramentas necessárias:

- 🐳 **Docker** + Docker Compose
- 📦 **Node.js LTS** + NPM
- 🌐 **NGINX** como reverse proxy
- 📊 **CloudWatch Agent**
- 🛡️ **Fail2Ban** + UFW
- ⚡ **AWS CLI v2**

## 🎯 Próximos Passos

1. **Pipeline CI/CD** com GitHub Actions
2. **Container Registry** (ECR)
3. **Load Balancer** (ALB)
4. **Auto Scaling Group**
5. **RDS Database**
6. **Monitoring Avançado**

## 🔧 Comandos Úteis

```bash
# Ver outputs
terraform output

# Conectar via SSH
terraform output -raw useful_commands | jq -r '.ssh_connect'

# Status da aplicação
terraform output -raw useful_commands | jq -r '.app_status'

# Logs da aplicação
terraform output -raw useful_commands | jq -r '.docker_logs'

# Destruir infraestrutura
terraform destroy
```

## 📚 Explicação DevSecOps

### **Por que Módulos?**
- **✅ Reutilização** - Módulos podem ser usados em diferentes projetos
- **✅ Testabilidade** - Cada módulo pode ser testado independentemente
- **✅ Manutenibilidade** - Separação clara de responsabilidades
- **✅ Escalabilidade** - Facilita crescimento da infraestrutura

### **Por que essa Arquitetura?**
- **🔒 Segurança First** - Todas as práticas seguem princípios de segurança
- **📊 Observabilidade** - Logs e métricas desde o primeiro dia
- **⚡ Performance** - Nginx como reverse proxy para otimização
- **💰 Custo-Efetivo** - Uso de Free Tier quando possível

### **Benefícios para DevSecOps**
- **🚀 Deploy Automatizado** - Infraestrutura como código
- **🔍 Auditabilidade** - Toda mudança é versionada
- **🛡️ Compliance** - Segurança integrada desde o design
- **📈 Escalabilidade** - Preparado para crescimento

---

**💡 Esta infraestrutura segue as melhores práticas de DevSecOps e está pronta para ser usada em produção com pequenos ajustes!** 