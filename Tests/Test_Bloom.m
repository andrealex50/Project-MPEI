function Test_Bloom()

    addpath('C:\Users\pcdoa\Project-MPEI');
    addpath('C:\Users\pcdoa\Project-MPEI\DataSets\');

    mensagens = 'TestMessages/mensagens_test_bloom.txt';  % Mensagens no geral, ficheiro principal
    disp("---Bloom Filter---");
    % (1) Bloom Filter
    mensagens_possiveis = bloom_filter(mensagens); % Chama a função bloom_filter que retorna o vetor binário

end