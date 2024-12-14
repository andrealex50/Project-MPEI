function mensagens_sem_similaridade = minHash(vetor_binario, mensagens, mensagens_treino)

    % Carregar os arquivos
    mensagens_suspeitas = readcell(mensagens, 'Delimiter', ',');
    % Ler o arquivo JSON contendo as mensagens de treino
    json_data = fileread(mensagens_treino);
    mensagens_treino_struct = jsondecode(json_data);
    mensagens_treino = {mensagens_treino_struct.content}'; % Extrair os textos das mensagens
    
    limiar_similaridade = 0.5;

    k = 100; % Número de funções de dispersão

    % Filtrar as mensagens com base no vetor binário
    mensagens_interessantes = mensagens_suspeitas(logical(vetor_binario), 1);

    % Gerar assinaturas para mensagens suspeitas
    num_mensagens = length(mensagens_interessantes);
    assinaturas_suspeitas = zeros(num_mensagens, k);
    for idx = 1:num_mensagens
        texto_mensagem = mensagens_interessantes{idx};
        if ischar(texto_mensagem) || isstring(texto_mensagem)
            texto_mensagem = lower(char(texto_mensagem)); % Normalizar o texto

            % Gerar shingles
            shingles = gerar_shingles(texto_mensagem);

            % Criar vetor binário para shingles
            vocabulario = unique(shingles);
            vetor_binario_shingles = ismember(vocabulario, shingles);

            % Gerar assinatura MinHash
            assinaturas_suspeitas(idx, :) = calcular_minHash(vetor_binario_shingles, k);
        end
    end

    % Gerar assinaturas para mensagens de treino
    num_treino = size(mensagens_treino, 1);
    assinaturas_treino = zeros(num_treino, k);
    for idx = 1:num_treino
        texto_mensagem = mensagens_treino{idx, 1};
        if ischar(texto_mensagem) || isstring(texto_mensagem)
            texto_mensagem = lower(char(texto_mensagem)); % Normalizar o texto

            % Gerar shingles
            shingles = gerar_shingles(texto_mensagem);

            % Criar vetor binário para shingles
            vocabulario = unique(shingles);
            vetor_binario_shingles = ismember(vocabulario, shingles);

            % Gerar assinatura MinHash
            assinaturas_treino(idx, :) = calcular_minHash(vetor_binario_shingles, k);
        end
    end

    % Calcular similaridade entre assinaturas suspeitas e de treino
    similaridades = zeros(num_mensagens, num_treino);
    mensagens_sem_similaridade = {};
    for i = 1:num_mensagens
        for j = 1:num_treino
            similaridade = calcular_similaridade(assinaturas_suspeitas(i, :), assinaturas_treino(j, :));
            similaridades(i, j) = similaridade;
            if similaridade < limiar_similaridade
                % Se a similaridade for abaixo do limiar, adicionar à lista de mensagens sem similaridade
                mensagens_sem_similaridade{end+1} = mensagens_interessantes{i};
                break; 
            end
        end
    end

    % Exibir resultados
    disp('Similaridades entre mensagens filtradas e mensagens de treino:');
    disp(similaridades);
end

% Função para gerar shingles
function shingles = gerar_shingles(texto)
    shingles = split(texto, ' ');
end

% Função para calcular assinaturas MinHash
function assinaturas = calcular_minHash(vetor_binario, k)
    % Número de shingles
    n = length(vetor_binario);

    % Inicializar assinaturas com infinito
    assinaturas = inf(1, k);

    % Funções de dispersão
    prime = 2147483647; 
    a = randi([1, prime-1], 1, k); 
    b = randi([0, prime-1], 1, k); 

    % Percorrer cada posição do vetor binário
    for i = 1:n
        if vetor_binario(i) == 1
            for j = 1:k
                hash_value = mod(mod(a(j) * i + b(j), prime), n);
                assinaturas(j) = min(assinaturas(j), hash_value);
            end
        end
    end
end

% Função para calcular similaridade entre assinaturas
function similaridade = calcular_similaridade(assinatura1, assinatura2)
    similaridade = sum(assinatura1 == assinatura2) / length(assinatura1);
end
