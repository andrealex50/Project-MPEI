function mensagens_suspeitas = bloom_filter(mensagens_analisar)
    asneiras = readFile('DataSets/en.txt');
    
    m = length(asneiras);        % número de linhas do en.txt
    p_fp = 0.01;    % probabilidade desejada de falsos positivos
    n = ceil((-m * log(p_fp)) / (0.693^2));   % número de bits do filtro
    k = round((n * 0.693) / m);      % número de funções de dispersão  

    % (1)
    filtro = inicializar(n);
    
    % Carregar as palavras de asneiras (do arquivo)
    for i = 1:length(asneiras)
        filtro = adicionarElemento(filtro, asneiras{i}, k);
    end
    
    % (2) Carregar os textos (mensagens) para análise
    textos = readFile(mensagens_analisar); % Substitua com o caminho do seu arquivo
     
    % Preallocate cell array for aggressive messages
    mensagens_suspeitas = cell(1, length(textos));
    count = 0;
    total_agressivos = 0; % Total number of aggressive messages

    for i = 1:length(textos)
        disp(['Analisando texto ', num2str(i), ': ', textos{i}]);
        
        % Tokenizar o texto em palavras
        palavras = lower(textos{i}); % Coloca tudo em minúsculas
        palavras = regexprep(palavras, '[^\w\s-]', ''); % Remove qualquer pontuação
        palavras_individuais = strsplit(palavras);

        % Verificar palavras no filtro
        encontrou_agressividade = false;
         % Verificar frases compostas no filtro
        for j = 1:length(asneiras)
            if contains(palavras, asneiras{j})
                disp(['-> Palavra agressiva encontrada: ', asneiras{j}]);
                encontrou_agressividade = true;
                break;
            end
        end
        
        if ~encontrou_agressividade
            % Verificar palavras individuais no filtro
            for j = 1:length(palavras_individuais)
                if membro(filtro, palavras_individuais{j}, k) && ismember(palavras_individuais{j}, asneiras)
                    disp(['-> Palavra agressiva encontrada: ', palavras_individuais{j}]);
                    encontrou_agressividade = true;
                    break;
                end
            end
        end
        
        if encontrou_agressividade
            total_agressivos = total_agressivos + 1;
            count = count + 1;
            mensagens_suspeitas{count} = textos{i}; % Adicionar mensagem à lista de resultados
        else
            disp('-> Palavra agressiva não encontrada');
        end
    end
    
    % Colcar apenas as mensagens agressivas na lista final
    mensagens_suspeitas = mensagens_suspeitas(1:count);
    
    % (3) Estatísticas
    percentagem_agressivos = (total_agressivos / length(textos)) * 100;
    disp(['Percentagem de textos com agressividade identificada: ', num2str(percentagem_agressivos), '%']);
end

function filtro = inicializar(n)
    filtro = zeros(1, n); % Preenche o vetor filtro com zeros
end

function filtro = adicionarElemento(filtro, elemento, k)
    for i = 1:k 
       h = mod(string2hash(elemento, 'djb2') + i, length(filtro)) + 1;
       filtro(h) = 1;
    end
end

function is_member = membro(filtro, elemento, k)
    is_member = true;
    for i = 1:k
        h = mod(string2hash(elemento, 'djb2') + i, length(filtro)) + 1;
        if filtro(h) == 0
            is_member = false;
            break;
        end
    end
end

function palavras = readFile(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('Não foi possível abrir o arquivo: %s', filename);
    end
    % Ler o conteúdo do arquivo e dividir em linhas
    linhas = fread(fid, '*char')';
    fclose(fid);
    % Separar em palavras, removendo espaços e quebras de linha
    palavras = strsplit(linhas, '\n');
    palavras = strtrim(palavras); % Remover espaços extras
    disp(palavras);
end
