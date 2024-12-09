% do ex6.2 a que apresentou melhor desempenho foi a DJB2
n = 8000;   % número de bits do filtro
m = 100;    % número de elementos do conjunto
k = 3;      % número de funções de dispersão

% Inicializar filtro com 0s

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


% (1)
filtro = inicializar(n);

% Palavras associadas a discurso de ódio
agressividade = {'ofensa1', 'insulto2', 'grupoX', 'grupoY', 'pessoaZ'};

for i = 1:length(agressividade)
    filtro = adicionarElemento(filtro, agressividade{i}, k);
end

% (2) Analisar se novos textos contêm palavras associadas a agressividade
textos = {
    'Esta é uma mensagem inofensiva.';
    'Mensagem com ofensa1 direcionada ao grupoX.';
    'Outro texto sem problemas.';
    'Alguém mencionou grupoY e insulto2 aqui.'
};

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
end

percentagem_agressivos = (total_agressivos / length(textos)) * 100;
disp(['Percentagem de textos com agressividade identificada: ', num2str(percentagem_agressivos), '%']);
