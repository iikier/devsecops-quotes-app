Write-Host "Setup DevSecOps Windows" -ForegroundColor Green

Write-Host "Verificando Git..." -ForegroundColor Yellow
git --version

Write-Host "Verificando Node.js..." -ForegroundColor Yellow
node --version
npm --version

Write-Host "Verificando Docker..." -ForegroundColor Yellow
docker --version

Write-Host "Instalando dependencias..." -ForegroundColor Yellow
npm install

Write-Host "Configurando SSH..." -ForegroundColor Yellow
$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force
}

$sshKeyPath = "$env:USERPROFILE\.ssh\devsecops-key"
if (-not (Test-Path $sshKeyPath)) {
    ssh-keygen -t rsa -b 4096 -f $sshKeyPath -N '""' -C "devsecops@windows"
    Write-Host "Chave SSH criada!" -ForegroundColor Green
    Write-Host "SUA CHAVE SSH PUBLICA:" -ForegroundColor Cyan
    Get-Content "$sshKeyPath.pub"
}

Write-Host "Configurando Terraform..." -ForegroundColor Yellow
if (Test-Path "terraform") {
    if (Test-Path "terraform\terraform.tfvars.example") {
        if (-not (Test-Path "terraform\terraform.tfvars")) {
            Copy-Item "terraform\terraform.tfvars.example" "terraform\terraform.tfvars"
            Write-Host "terraform.tfvars criado!" -ForegroundColor Green
        }
    }
}

Write-Host "Criando scripts..." -ForegroundColor Yellow

$securityScript = @'
Write-Host "Security Scan..." -ForegroundColor Green
npm audit --json > security-reports\npm-audit.json
Write-Host "Scan concluido!" -ForegroundColor Green
'@
$securityScript | Out-File "scripts\security-scan.ps1" -Encoding UTF8

$deployScript = @'
Write-Host "Deploy Local..." -ForegroundColor Green
docker build -t devsecops-app .
docker stop devsecops-app 2>$null
docker rm devsecops-app 2>$null
docker run -d --name devsecops-app -p 3000:3000 devsecops-app
Write-Host "App rodando: http://localhost:3000" -ForegroundColor Green
'@
$deployScript | Out-File "scripts\local-deploy.ps1" -Encoding UTF8

if (-not (Test-Path "security-reports")) {
    New-Item -ItemType Directory -Path "security-reports" -Force
}

Write-Host ""
Write-Host "SETUP CONCLUIDO!" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. aws configure" -ForegroundColor White
Write-Host "2. Editar terraform\terraform.tfvars" -ForegroundColor White
Write-Host "3. cd terraform; terraform init" -ForegroundColor White
Write-Host "4. .\scripts\local-deploy.ps1" -ForegroundColor White
Write-Host "" 