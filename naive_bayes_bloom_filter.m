
%Isto e para treinar o classificador
texts = {
    'You are an idiot';
    'I am so angry at you';
    'This is nice';
    'You did a great job';
    'I love you';
    'I hate you';
    'You are amazing';
    'I will hurt you now';
    'Good job, well done';
    'Why are you so dumb?' 
};

%isto tambem e para treinar o classificador
labels = {'aggressive', 'aggressive', 'non-aggressive', 'non-aggressive', 'non-aggressive', ...
          'aggressive', 'non-aggressive', 'aggressive', 'non-aggressive', 'aggressive'};

n = 8000;   % tamanho do filtro
m = 100;    % tamanho do conjunto
k = 3;      % número de funções de dispersão
filtro = inicializar(n);

% Palavras associadas a discurso de ódio
agressividade = {'ofensa1', 'insulto2', 'grupoX', 'grupoY', 'pessoaZ'};

for i = 1:length(agressividade)
    filtro = adicionarElemento(filtro, agressividade{i}, k);
end

cleanTexts = cellfun(@(x) preprocessText(x, filtro, k), texts, 'UniformOutput', false);
vocabulary = buildVocabulary(cleanTexts);
X = countWordOccurrencesBinary(cleanTexts, vocabulary);

Y = categorical(labels);
Mdl = fitcnb(X, Y, 'Distribution', 'mn');

newText = 'I love you';  %%%%%% Frase a ser testada
cleanNewText = preprocessText(newText, filtro, k);
newX = countWordOccurrencesBinary({cleanNewText}, vocabulary);  
predictedClass = predict(Mdl, newX);

disp(['Predicted class: ', char(predictedClass)]);




%Funcoes helper
% Pre processar texto e verificar o bloom filter
% Responsável por limpar e processar o texto
function cleanText = preprocessText(text, filtro, k)
    text = lower(text);                                                             % passa para minusculas
    text = regexprep(text, '[^\w\s]', '');                                          % remove a pontuação
    stopWords = ["i", "the", "at", "on", "and", "of", "to", "a", "in", "it"];
    words = setdiff(strsplit(text), stopWords);                                     % remove stopwords (palavras que não acrescentam muito significado a uma frase)                                                                            
    
    % Verificar se as palavras estao no bloom filter
    is_aggressive = any(cellfun(@(word) membro(filtro, word, k), words));           % se o bloom filter indicar agressividade, marca o texto como agressivo
    
    if is_aggressive
        cleanText = '';  % Se for agressive return vazio
    else
        cleanText = strjoin(words);
    end
end


% Cria um vocabulario unico de todas as palavras nos textos
function vocabulary = buildVocabulary(cleanTexts)
    allWords = {};
    totalWords = 0;
    
    % Number total de palavars
    for i = 1:length(cleanTexts)
        totalWords = totalWords + length(strsplit(cleanTexts{i}));
    end
    
    % Pre alocar espaco para o allWords 
    allWords = cell(1, totalWords);
    currentIndex = 1;
    
    % Recolher palavras dos documentos
    for i = 1:length(cleanTexts)
        wordsInDoc = strsplit(cleanTexts{i});
        for j = 1:length(wordsInDoc)
            allWords{currentIndex} = wordsInDoc{j};
            currentIndex = currentIndex + 1;
        end
    end
    
    vocabulary = unique(allWords);
end

% Cria uma matriz binária que indica a presença ou ausencia de palavras 
function wordCounts = countWordOccurrencesBinary(cleanTexts, vocabulary)
    wordCounts = zeros(length(cleanTexts), length(vocabulary));
    
    for i = 1:length(cleanTexts)
        wordsInDoc = strsplit(cleanTexts{i});
        for j = 1:length(vocabulary)
            wordCounts(i, j) = any(strcmp(wordsInDoc, vocabulary{j}));
        end
    end
end


% Bloom filter
% Usado para verificar se a palavra está associado a um discurso agressivo
function filtro = inicializar(n)
    filtro = zeros(1, n); % Initialize filter with zeros
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

% string2hash function for 'djb2'
function hash = string2hash(str, method)
    if strcmp(method, 'djb2')
        hash = uint32(5381);  % Initial value
        for i = 1:length(str)
            hash = mod((hash * 33) + double(str(i)), 2^32);
        end
    else
        error('Unknown hash method');
    end
end
