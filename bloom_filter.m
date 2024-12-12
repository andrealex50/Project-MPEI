function resultados = bloom_filter()
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
    textos = readFile('mensagens.txt'); % Substitua com o caminho do seu arquivo
     
    resultados = zeros(1, length(textos));

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
            end
        end
        
        if ~encontrou_agressividade
            disp('-> Palavra suspeita');
        end
    end
    
    % (3) Estatísticas
    % Exemplo: determinar a percentagem de textos com palavras agressivas
    total_agressivos = 0;
    for i = 1:length(textos)
        palavras = strsplit(lower(textos{i}), {' ', '.', ','});
        for j = 1:length(palavras)
            if membro(filtro, palavras{j}, k)
                total_agressivos = total_agressivos + 1;
                break;
            end
        end

        % Guardar resultado num vetor binário
        if encontrou_agressividade
            resultados(i) = 1;
        else
            resultados(i) = 0;
        end
    end
    
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