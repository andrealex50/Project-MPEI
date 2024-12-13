function agressividade()

    mensagens_suspeitas = 'mensagens.txt';  % Mensagens no geral, ficheiro principal
    % (1) Bloom Filter
    vetor_binario = bloom_filter(mensagens_suspeitas); % Chama a função bloom_filter que retorna o vetor binário

    % (2) minHash
    mensagens_treino = 'aggressive_texts.json';    % Mensagens que só contém asneiras
    mensagens_sem_similaridade = minHash(vetor_binario, mensagens_suspeitas, mensagens_treino);   % Retorna mensagens que não encontraram similaridade

    % (3) Naive Bayes
    if ~isempty(mensagens_sem_similaridade)
        % Chama a função naive_bayes com as mensagens sem similaridade 
        resultados = naive_bayes(mensagens_sem_similaridade); 
        
        % Exibe os resultados 
        for i = 1:length(resultados) 
            fprintf('Mensagem: %s\nClassificação: %s\n', mensagens_sem_similaridade{i}, resultados{i}); 
        end 
    else 
        disp('Nenhuma mensagem encontrada para análise.');
    end
end