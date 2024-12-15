function results = naive_bayes(messages)
    % Check if the trained model already exists
    if isfile('DataSets/trainedModel.mat')
        disp('Loading trained model...');
        load('DataSets/trainedModel.mat', 'Mdl', 'vocabulary');
    else
        disp('Training new model...');

        % Load and parse the JSON dataset
        filename = 'DataSets/Dataset_Naive_Bayes.json'; % Adjust this to your JSON file path
        fid = fopen(filename);
        if fid == -1
            error('Cannot open the file: %s', filename);
        end

        rawData = fread(fid, inf); % Read the entire file
        fclose(fid);
        rawText = char(rawData'); % Convert to character array

        jsonData = jsondecode(rawText); % Decode JSON file into MATLAB struct array

        % Initialize text and label arrays
        texts = {};
        labels = [];

        % Extract texts and labels from JSON
        for i = 1:length(jsonData)
            if isfield(jsonData(i), 'content') && isfield(jsonData(i), 'label')
                texts{end+1} = jsonData(i).content; % Extract the text content
                labels(end+1) = str2double(jsonData(i).label); % Extract the label and convert to numeric
            end
        end

        % Convert texts to a column cell array
        texts = texts';

        % Map numeric labels to categorical labels
        mappedLabels = cell(size(labels));
        mappedLabels(labels == 1) = {'aggressive'};
        mappedLabels(labels == 0) = {'non-aggressive'};

        % Convert mapped labels to categorical array
        Y = categorical(mappedLabels);

        % Debugging: Ensure labels are correctly mapped
        disp('Unique categories in Y:');
        disp(categories(Y));

        % Preprocess texts
        cleanTexts = cell(size(texts));
        for i = 1:length(texts)
            cleanTexts{i} = preprocessText(texts{i});
        end

        % Handle negations
        cleanTexts = handleNegations(cleanTexts);

        % Build vocabulary from preprocessed texts
        vocabulary = buildVocabulary(cleanTexts);

        % Create a binary word occurrence matrix
        X = countWordOccurrencesBinary(cleanTexts, vocabulary);

        % Split data into 70% training and 30% testing sets
        cv = cvpartition(Y, 'Holdout', 0.3);
        XTrain = X(training(cv), :);
        YTrain = Y(training(cv));
        XTest = X(test(cv), :);
        YTest = Y(test(cv));

        % Train the Naive Bayes model
        Mdl = fitcnb(XTrain, YTrain, 'DistributionNames', 'mn');

        % Evaluate model performance on the test set
        predictedLabels = predict(Mdl, XTest);
        truePositives = sum((predictedLabels == 'aggressive') & (YTest == 'aggressive'));
        falsePositives = sum((predictedLabels == 'aggressive') & (YTest == 'non-aggressive'));
        falseNegatives = sum((predictedLabels == 'non-aggressive') & (YTest == 'aggressive'));

        precision = truePositives / (truePositives + falsePositives);
        recall = truePositives / (truePositives + falseNegatives);
        f1Score = 2 * (precision * recall) / (precision + recall);

        fprintf('Precision: %.2f\n', precision);
        fprintf('Recall: %.2f\n', recall);
        fprintf('F1 Score: %.2f\n', f1Score);

        % Save the trained model and vocabulary to a file
        save('DataSets/trainedModel.mat', 'Mdl', 'vocabulary');
    end

    % Analyze messages
    results = cell(size(messages));
    for i = 1:length(messages)
        cleanText = preprocessText(messages{i});
        cleanText = handleNegations({cleanText});
        newX = countWordOccurrencesBinary({cleanText}, vocabulary);
        predictedClass = predict(Mdl, newX);
        results{i} = char(predictedClass);
    end
end

% --- Helper Functions ---
% Function to preprocess text: lowercase, remove punctuation, stop words, and URLs
function cleanWords = preprocessText(text)
    text = lower(text); % Convert to lowercase
    text = regexprep(text, 'http[s]?://\S+|www\.\S+', ''); % Remove URLs
    text = regexprep(text, '[^\w\s]', ''); % Remove punctuation and special characters
    stopWords = ["i", "the", "at", "on", "and", "of", "to", "a", "in", "it"];
    cleanWords = setdiff(strsplit(text), stopWords); % Remove stop words and split into words
end

% Function to handle negations
function cleanTexts = handleNegations(cleanTexts)
    negationWords = ["not", "no", "never", "none"];
    for i = 1:length(cleanTexts)
        words = cleanTexts{i};
        hasNegation = false;
        for j = 1:length(words)
            if ismember(words{j}, negationWords)
                hasNegation = true;
            elseif hasNegation
                words{j} = ['not_' words{j}];
                hasNegation = false;
            end
        end
        cleanTexts{i} = words;
    end
end

% Function to build a vocabulary from the preprocessed texts
function vocabulary = buildVocabulary(cleanTexts)
    allWords = horzcat(cleanTexts{:}); % Concatenate all words from all texts
    vocabulary = unique(allWords); % Get unique words
end

% Function to create a binary word occurrence matrix
function wordCounts = countWordOccurrencesBinary(cleanTexts, vocabulary)
    wordCounts = zeros(length(cleanTexts), length(vocabulary));
    h = waitbar(0, 'Counting word occurrences...');
    for i = 1:length(cleanTexts)
        wordsInDoc = cleanTexts{i};
        for j = 1:length(vocabulary)
            wordCounts(i, j) = any(strcmp(wordsInDoc, vocabulary{j}));
        end
        waitbar(i / length(cleanTexts), h);
    end
    close(h);
end
