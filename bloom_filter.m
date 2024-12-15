function mensagens_agressivas = bloom_filter(mensagens_suspeitas)
    n = 8000;   % número de bits do filtro
    m = 100;    % número de elementos do conjunto
    k = 3;      % número de funções de dispersão  
    
    % (1)
    filtro = inicializar(n);
    
    % Carregar as palavras de asneiras (do arquivo)
    asneiras = readFile('en.txt'); % Substitua com o caminho do seu arquivo
    for i = 1:length(asneiras)
        filtro = adicionarElemento(filtro, asneiras{i}, k);
    end
    
    % (2) Carregar os textos (mensagens) para análise
    textos = readFile(mensagens_suspeitas); % Substitua com o caminho do seu arquivo
     
    % Preallocate cell array for aggressive messages
    mensagens_agressivas = cell(1, length(textos));
    count = 0;
    total_agressivos = 0; % Total number of aggressive messages

    for i = 1:length(textos)
        disp(['Analisando texto ', num2str(i), ': ', textos{i}]);
        
        % Tokenizar o texto em palavras
        palavras = strsplit(lower(textos{i}), {' ', '.', ','});
        
        % Verificar palavras no filtro
        encontrou_agressividade = false;
        for j = 1:length(palavras)
            if membro(filtro, palavras{j}, k)
                disp(['-> Palavra agressiva encontrada: ', palavras{j}]);
                encontrou_agressividade = true;
                break;
            end
        end
        
        if encontrou_agressividade
            count = count + 1;
            total_agressivos = total_agressivos + 1;
            mensagens_agressivas{count} = textos{i}; % Adicionar mensagem à lista de resultados
        else
            disp('-> Palavra suspeita');
        end
    end
    
    % Colcar apenas as mensagens agressivas na lista final
    mensagens_agressivas = mensagens_agressivas(1:count);
    
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
end
