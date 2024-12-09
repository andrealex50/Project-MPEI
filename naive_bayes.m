% Leitura dos dados do arquivo CSV
opts = detectImportOptions('labeled_data.csv', 'VariableNamingRule', 'preserve');
data = readtable('labeled_data.csv', opts);

% Extrair a coluna de textos e classes da tabela
texts = data.tweet;
labels = data.class;

% Mapear classes para categorias 'aggressive' e 'non-aggressive'
mappedLabels = cell(size(labels));
mappedLabels(labels == 0) = {'aggressive'}; % Classe 0 é 'aggressive'
mappedLabels(labels == 1) = {'aggressive'}; % Classe 1 é 'aggressive'
mappedLabels(labels == 2) = {'non-aggressive'}; % Classe 2 é 'non-aggressive'

% Inicializar cell array para textos pré-processados 
cleanTexts = cell(size(texts)); 

% Loop para pré-processar cada texto 
for i = 1:length(texts) 
    cleanTexts{i} = preprocessText(texts{i});
end

% Construir um vocabulário único a partir dos textos pré-processados
vocabulary = buildVocabulary(cleanTexts);

% Contar as ocorrências binárias das palavras do vocabulário nos textos
X = countWordOccurrencesBinary(cleanTexts, vocabulary);

% Converter rótulos mapeados para categorias
Y = categorical(mappedLabels);

% Treinar o modelo Naive Bayes usando a distribuição multinomial
Mdl = fitcnb(X, Y, 'Distribution', 'mn');

% Prever rótulos para os dados de treinamento para avaliação
predictedLabels = predict(Mdl, X);

% Calcular precisão, recall e F1 score
truePositives = sum((predictedLabels == 'aggressive') & (Y == 'aggressive'));
falsePositives = sum((predictedLabels == 'aggressive') & (Y == 'non-aggressive'));
falseNegatives = sum((predictedLabels == 'non-aggressive') & (Y == 'aggressive'));

precision = truePositives / (truePositives + falsePositives); % Cálculo da precisão
recall = truePositives / (truePositives + falseNegatives); % Cálculo do recall
f1Score = 2 * (precision * recall) / (precision + recall); % Cálculo do F1 score

fprintf('Precision: %.2f\n', precision);
fprintf('Recall: %.2f\n', recall);
fprintf('F1 Score: %.2f\n', f1Score);

% Testar novo texto e prever a sua classe
newText = 'You are the worst person I have ever met';  
cleanNewText = preprocessText(newText); % Pré-processar novo texto
newX = countWordOccurrencesBinary({cleanNewText}, vocabulary); % Contar ocorrências binárias no novo texto
predictedClass = predict(Mdl, newX); % Prever classe do novo texto

disp(['Predicted class: ', char(predictedClass)]);

% Função para pré-processar textos: converter para minúsculas, remover pontuação e stop words
function cleanWords = preprocessText(text)
    text = lower(text); % Converter texto para minúsculas
    text = regexprep(text, '[^\w\s]', ''); % Remover pontuação
    stopWords = ["i", "the", "at", "on", "and", "of", "to", "a", "in", "it"];
    cleanWords = setdiff(strsplit(text), stopWords); % Remover stop words e retornar lista de palavras
end

% Função para construir vocabulário único a partir dos textos pré-processados
function vocabulary = buildVocabulary(cleanTexts)
    allWords = {}; % Inicializar lista para todas as palavras
    totalWords = 0; % Inicializar contador de palavras
    
    % Contar número total de palavras nos textos
    for i = 1:length(cleanTexts)
        totalWords = totalWords + length(cleanTexts{i});
    end
    
    % Pre alocar espaço para todas as palavras baseando-se no número total de palavras
    allWords = cell(1, totalWords);
    currentIndex = 1; % Inicializar índice atual
    
    % Coletar palavras de cada documento
    for i = 1:length(cleanTexts)
        wordsInDoc = cleanTexts{i};
        for j = 1:length(wordsInDoc)
            allWords{currentIndex} = wordsInDoc{j}; % Adicionar palavra à lista
            currentIndex = currentIndex + 1;
        end
    end
    
    vocabulary = unique(allWords); % Encontrar palavras únicas para formar o vocabulário
end

% Função para contar ocorrências binárias de palavras do vocabulário nos textos
function wordCounts = countWordOccurrencesBinary(cleanTexts, vocabulary)
    wordCounts = zeros(length(cleanTexts), length(vocabulary)); % Inicializar matriz binária
    
    h = waitbar(0, 'Counting word occurences...');
    % Contar presença ou ausência de palavras do vocabulário em cada texto
    for i = 1:length(cleanTexts)
        wordsInDoc = cleanTexts{i};
        for j = 1:length(vocabulary)
            wordCounts(i, j) = any(strcmp(wordsInDoc, vocabulary{j})); % Marcar presença da palavra
        end

        waitbar(i/ length(cleanTexts), h);
    end
    close(h);
end
