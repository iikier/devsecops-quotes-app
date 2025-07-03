document.addEventListener('DOMContentLoaded', () => {
    const quoteTextElement = document.getElementById('quote-text');
    const newQuoteBtn = document.getElementById('new-quote-btn');

    const fetchQuote = async () => {
        // Mostra um feedback de carregamento para o usuário
        quoteTextElement.textContent = 'Carregando nova dica...';
        
        try {
            // Faz a chamada para nossa API backend
            const response = await fetch('/api/quote');

            // Verifica se a resposta da rede foi bem-sucedida
            if (!response.ok) {
                throw new Error(`Erro de rede: ${response.status}`);
            }

            const data = await response.json();
            
            // ATUALIZAÇÃO SEGURA: Usa textContent para prevenir XSS
            quoteTextElement.textContent = data.quote;

        } catch (error) {
            console.error('Falha ao buscar a dica:', error);
            quoteTextElement.textContent = 'Não foi possível carregar a dica. Por favor, tente novamente mais tarde.';
        }
    };

    // Adiciona o evento de clique no botão
    newQuoteBtn.addEventListener('click', fetchQuote);

    // Carrega a primeira dica assim que a página é aberta
    fetchQuote();
}); 