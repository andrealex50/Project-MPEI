function mensagens_sem_similaridade = minHash(mensagens, caminho_json_treino)
    % Carregar os arquivos
    % Ler o arquivo JSON contendo as mensagens de treino
    json_data = fileread(caminho_json_treino);
    mensagens_treino_struct = jsondecode(json_data);
    mensagens_treino = {mensagens_treino_struct.content}'; % Extrair os textos das mensagens

    limiar_similaridade = 0.7;
    k = 100; % Número de funções de dispersão

    % Gerar assinaturas para mensagens suspeitas
    num_mensagens = length(mensagens);
    assinaturas_suspeitas = zeros(num_mensagens, k);
    for idx = 1:num_mensagens
        texto_mensagem = mensagens{idx};
        if ischar(texto_mensagem) || isstring(texto_mensagem)
            texto_mensagem = lower(char(texto_mensagem)); % Normalizar o texto

            % Gerar shingles
            shingles = gerar_shingles(texto_mensagem);

            % Gerar assinatura MinHash
            assinaturas_suspeitas(idx, :) = calcular_minHash(shingles, k);
            disp(['MinHash Signature for message ', num2str(idx), ': ', num2str(assinaturas_suspeitas(idx, :))]);
        end
    end

    % Gerar assinaturas para mensagens de treino
    num_treino = length(mensagens_treino);
    assinaturas_treino = zeros(num_treino, k);
    for idx = 1:num_treino
        texto_mensagem = mensagens_treino{idx};
        if ischar(texto_mensagem) || isstring(texto_mensagem)
            texto_mensagem = lower(char(texto_mensagem)); % Normalizar o texto

            % Gerar shingles
            shingles = gerar_shingles(texto_mensagem);

            % Gerar assinatura MinHash
            assinaturas_treino(idx, :) = calcular_minHash(shingles, k);
            disp(['MinHash Signature for training message ', num2str(idx), ': ', num2str(assinaturas_treino(idx, :))]);
        end
    end

    % Calcular similaridade entre assinaturas suspeitas e de treino
    similaridades = zeros(num_mensagens, num_treino);
    mensagens_com_similaridade = {};
    mensagens_sem_similaridade = {};
    for i = 1:num_mensagens
        max_similaridade = 0; % Inicializar o valor máximo de similaridade
        for j = 1:num_treino
            similaridade = calcular_similaridade(assinaturas_suspeitas(i, :), assinaturas_treino(j, :));
            similaridades(i, j) = similaridade;
            if similaridade > limiar_similaridade
                mensagens_com_similaridade{end+1} = mensagens{i};
            end
            max_similaridade = max(max_similaridade, similaridade); % Atualizar o valor máximo
        end
        % Exibir a mensagem e o valor máximo de similaridade encontrado
        disp(['Mensagem: ', mensagens{i}]);
        disp(['Maior similaridade: ', num2str(max_similaridade)]);
    end

    % Converter mensagens para strings manualmente (sem usar cellfun)
    mensagens_str = cell(1, num_mensagens);
    for i = 1:num_mensagens
        mensagens_str{i} = char(mensagens{i});
    end

    mensagens_com_similaridade_str = cell(1, length(mensagens_com_similaridade));
    for i = 1:length(mensagens_com_similaridade)
        mensagens_com_similaridade_str{i} = char(mensagens_com_similaridade{i});
    end

    % Determinar mensagens sem similaridade
    mensagens_sem_similaridade_str = setdiff(mensagens_str, mensagens_com_similaridade_str, 'stable');

    % Recuperar mensagens originais
    mensagens_sem_similaridade = {};
    for i = 1:num_mensagens
        if ismember(char(mensagens{i}), mensagens_sem_similaridade_str)
            mensagens_sem_similaridade{end+1} = mensagens{i};
        end
    end
end

% Função para gerar shingles (n-grams)
function shingles = gerar_shingles(texto)
    % Tokenizar texto e criar shingles
    tokens = lower(strsplit(texto));
    shingles = {};
    for i = 1:(length(tokens) - 1) % Gerar bigrams (shingles de 2 palavras)
        shingles{end+1} = strjoin(tokens(i:i+1));
    end
end

% Função para calcular assinaturas MinHash
function assinaturas = calcular_minHash(shingles, k)
    % Inicializar assinaturas com infinito
    assinaturas = inf(1, k);
    
    % Funções de dispersão (hashes)
    a = randi([1, 2^32-1], 1, k); 
    b = randi([0, 2^32-1], 1, k); 

    % Gerar assinatura MinHash
    for i = 1:length(shingles)
        shingle_hash = string2hash(shingles{i}); % Hash do shingle
        for j = 1:k
            hash_value = mod(a(j) * shingle_hash + b(j), 2^32);
            assinaturas(j) = min(assinaturas(j), hash_value);
        end
    end
    disp(['Generated MinHash Signature: ', num2str(assinaturas)]);
end

% Função para calcular similaridade entre assinaturas
function similaridade = calcular_similaridade(assinatura1, assinatura2)
    similaridade = sum(assinatura1 == assinatura2) / length(assinatura1);
    disp(['Calculated similarity: ', num2str(similaridade)]);
end

% Função para gerar um hash a partir de uma string
function hash = string2hash(str)
    hash = mod(sum(double(char(str))), 2^32);
end
