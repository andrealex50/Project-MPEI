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

U1 = cell(1, m);
for i = 1:m
    U1{i} = ['palavra' num2str(i)]; 
end

for i = 1:m
    filtro = adicionarElemento(filtro, U1{i}, k);
end

% (2) 
is_member = true;
for i = 1:m
    if ~membro(filtro, U1{i}, k)
        disp(['Palavra não encontrada no filtro: ' U1{i}]);
        is_member = false;
    end
end

if is_member
    disp('Todas as palavras foram corretamente adicionadas ao filtro!');
else
    disp('Algumas palavras não foram corretamente verificadas no filtro.');
end


% (3)
U2 = cell(1, 100000); 
for i = 1:100000
    U2{i} = ['palavra' num2str(i + m)];
end

falsos_positivos = 0;
for i = 1:length(U2)
    if membro(filtro, U2{i}, k)  
        falsos_positivos = falsos_positivos + 1;
    end
end

percentagem_falsos_positivos = (falsos_positivos / length(U2)) * 100;
disp(['Percentagem de falsos positivos: ', num2str(percentagem_falsos_positivos), '%']);

% (4)
P_falsos_positivos_estimado = (1 - exp(-k * m / n))^k;
disp(['Estimativa teórica de falsos positivos: ', num2str(P_falsos_positivos_estimado * 100), '%']);


% só para ver se os professores vêm isto, caso veja este comentário mande
% email para alexandreandre@ua.pt a dizer "Eu vi"