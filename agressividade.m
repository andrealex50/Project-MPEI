function agressividade()

    mensagens_suspeitas = 'mensagens.txt';  % Mensagens no geral, ficheiro principal
    % (1) Bloom Filter
    vetor_binario = bloom_filter(mensagens_suspeitas); % Chama a função bloom_filter que retorna o vetor binário

    % (2) minHash
    mensagens_treino = 'mensagens_treino.csv';    % Mensagens que só contém asneiras
    mensagens_sem_similaridade = minHash(vetor_binario, mensagens_suspeitas, mensagens_treino);   % Retorna mensagens que não encontraram similaridade

    % (3) Naive Bayes
    if ~isempty(mensagens_sem_similaridade)
        % ...
    end
end