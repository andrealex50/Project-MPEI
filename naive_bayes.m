% Samples
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

labels = {'aggressive', 'aggressive', 'non-aggressive', 'non-aggressive', 'non-aggressive', ...
          'aggressive', 'non-aggressive', 'aggressive', 'non-aggressive', 'aggressive'};

cleanTexts = cellfun(@(x) preprocessText(x), texts, 'UniformOutput', false);
vocabulary = buildVocabulary(cleanTexts);
X = countWordOccurrencesBinary(cleanTexts, vocabulary);

Y = categorical(labels);
Mdl = fitcnb(X, Y, 'Distribution', 'mn');

newText = 'I like you';  
cleanNewText = preprocessText(newText);
newX = countWordOccurrencesBinary({cleanNewText}, vocabulary);  
predictedClass = predict(Mdl, newX);

disp(['Predicted class: ', char(predictedClass)]);




% Funcoes que sao utlizadas em cima
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
    
    % Contar numero de palavras
    for i = 1:length(cleanTexts)
        totalWords = totalWords + length(strsplit(cleanTexts{i}));
    end
    
    % Pre alocar espac para o allwords baseado no numero de palavras
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
