% Leitura dos dados do arquivo CSV
opts = detectImportOptions('labeled_data.csv', 'VariableNamingRule', 'preserve');
data = readtable('labeled_data.csv', opts);

% Verificar nomes das colunas
disp(data.Properties.VariableNames);

% Converter a coluna de textos em um cell array
texts = data.tweet;

% Converter a coluna de classes em um array
labels = data.class;

% Mapear classes para categorias
mappedLabels = cell(size(labels));
mappedLabels(labels == 0) = {'aggressive'}; % 'hate' é 'aggressive'
mappedLabels(labels == 1) = {'aggressive'}; % 'offensive' é 'aggressive'
mappedLabels(labels == 2) = {'non-aggressive'}; % 'neither' é 'non-aggressive'

cleanTexts = cellfun(@(x) preprocessText(x), texts, 'UniformOutput', false);
vocabulary = buildVocabulary(cleanTexts);
X = countWordOccurrencesBinary(cleanTexts, vocabulary);

Y = categorical(mappedLabels);
Mdl = fitcnb(X, Y, 'Distribution', 'mn');

% Testar novo texto
newText = 'I like you';  
cleanNewText = preprocessText(newText);
newX = countWordOccurrencesBinary({cleanNewText}, vocabulary);  
predictedClass = predict(Mdl, newX);

disp(['Predicted class: ', char(predictedClass)]);

% Funções que são utilizadas em cima
function cleanText = preprocessText(text)
    text = lower(text);
    text = regexprep(text, '[^\w\s]', '');
    stopWords = ["i", "the", "at", "on", "and", "of", "to", "a", "in", "it"];
    text = strjoin(setdiff(strsplit(text), stopWords));
    cleanText = text;
end

function vocabulary = buildVocabulary(cleanTexts)
    allWords = {};
    totalWords = 0;
    
    % Contar número de palavras
    for i = 1:length(cleanTexts)
        totalWords = totalWords + length(strsplit(cleanTexts{i}));
    end
    
    % Pre alocar espaço para o allWords baseado no número de palavras
    allWords = cell(1, totalWords);
    currentIndex = 1;
    
    for i = 1:length(cleanTexts)
        wordsInDoc = strsplit(cleanTexts{i});
        for j = 1:length(wordsInDoc)
            allWords{currentIndex} = wordsInDoc{j};
            currentIndex = currentIndex + 1;
        end
    end
    
    vocabulary = unique(allWords);
end

function wordCounts = countWordOccurrencesBinary(cleanTexts, vocabulary)
    wordCounts = zeros(length(cleanTexts), length(vocabulary));
    
    for i = 1:length(cleanTexts)
        wordsInDoc = strsplit(cleanTexts{i});
        for j = 1:length(vocabulary)
            wordCounts(i, j) = any(strcmp(wordsInDoc, vocabulary{j}));
        end
    end
end
