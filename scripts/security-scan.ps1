Write-Host "Security Scan..." -ForegroundColor Green
npm audit --json > security-reports\npm-audit.json
Write-Host "Scan concluido!" -ForegroundColor Green
