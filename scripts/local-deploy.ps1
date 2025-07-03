Write-Host "Deploy Local..." -ForegroundColor Green
docker build -t devsecops-app .
docker stop devsecops-app 2>$null
docker rm devsecops-app 2>$null
docker run -d --name devsecops-app -p 3000:3000 devsecops-app
Write-Host "App rodando: http://localhost:3000" -ForegroundColor Green
