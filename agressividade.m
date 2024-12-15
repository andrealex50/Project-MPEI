function agressividade()

    mensagens_a_analisar = 'DataSets/mensagens.txt';  % Mensagens no geral, ficheiro principal
    disp("---Bloom Filter---");
    % (1) Bloom Filter
    mensagens_possiveis = bloom_filter(mensagens_a_analisar); % Chama a função bloom_filter que retorna o vetor binário

    disp("---MinHash---");
    % (2) minHash
    mensagens_treino = 'DataSets/aggressive_texts.json';    % Mensagens que só contém asneiras
    mensagens_sem_similaridade = minhash_similarity(mensagens_possiveis, mensagens_treino);   % Retorna mensagens que não encontraram similaridade

    disp("---Naive Bayes---");
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