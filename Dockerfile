# Usa a imagem oficial do Node.js baseada em Alpine Linux.
# É uma imagem leve e segura, ideal para produção.
FROM node:lts-alpine

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /usr/src/app

# Copia os arquivos de definição de dependência.
# O Docker usa cache em camadas, então este passo só será re-executado se estes arquivos mudarem.
COPY package*.json ./

# Instala apenas as dependências de produção.
# A flag --only=production é uma otimização de segurança crucial.
RUN npm install --only=production

# Copia o restante dos arquivos da aplicação para o diretório de trabalho.
COPY . .

# Expõe a porta que a aplicação usa dentro do contêiner.
EXPOSE 3000

# Define o comando padrão para iniciar o contêiner.
CMD [ "node", "server.js" ]