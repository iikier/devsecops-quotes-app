const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Coleção de dicas de DevSecOps
const devsecopsQuotes = [
    "A segurança é uma responsabilidade de todos, não apenas de um time.",
    "Automatize a segurança para escalar com a velocidade do DevOps.",
    "Faça o 'shift-left': encontre e corrija vulnerabilidades o mais cedo possível no ciclo de vida.",
    "Infraestrutura como Código (IaC) deve ser escaneada em busca de falhas de configuração.",
    "Monitore suas aplicações em produção em busca de atividades suspeitas.",
    "Use o princípio do menor privilégio para acessos e permissões.",
    "A segurança não pode ser um gargalo. Integre-a de forma transparente no pipeline.",
    "Patches de segurança não são opcionais. Automatize as atualizações de dependências.",
    "Segurança é um processo de melhoria contínua, não um estado final."
];

// Servir arquivos estáticos da pasta 'public' de forma segura
app.use(express.static(path.join(__dirname, 'public')));

// Endpoint da API para obter uma dica aleatória
app.get('/api/quote', (req, res) => {
    const randomIndex = Math.floor(Math.random() * devsecopsQuotes.length);
    res.json({ quote: devsecopsQuotes[randomIndex] });
});

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
}); 