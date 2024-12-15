function not_similar_messages = minHash(messages_to_analyze, json_filename)
    % Shingle length (n-grams)
    shingle_length = 2;  % For example, create 2-grams

    % Read the JSON file (training dataset)
    raw_data = fileread(json_filename);
    messages = jsondecode(raw_data);

    % Extract the content of each training message
    num_messages = length(messages);
    training_contents = cell(1, num_messages);
    for i = 1:num_messages
        training_contents{i} = messages(i).content;
    end

    % Initialize list for not similar messages
    not_similar_messages = {};

    % Tokenize and generate shingles for each message to analyze
    % Preprocess all messages to analyze at once
    analyzed_signatures = cell(1, length(messages_to_analyze));
    for idx = 1:length(messages_to_analyze)
        input_message = messages_to_analyze{idx};

        % Tokenize the input message (remove punctuation before tokenizing)
        input_message_cleaned = regexprep(input_message, '[^\w\s]', '');  % Remove punctuation
        input_tokens = unique(strsplit(lower(input_message_cleaned)));  % Tokenize and make lowercase

        % Generate shingles for the input message
        input_shingles = generate_shingles(input_tokens, shingle_length);

        % Number of hash functions
        num_hashes = 200;

        % Generate MinHash signature for the input message shingles
        analyzed_signatures{idx} = minhash_signature(input_shingles, num_hashes);
    end

    % Compare each message to analyze with the training set in a more efficient way
    for idx = 1:length(messages_to_analyze)
        input_signature = analyzed_signatures{idx};
        input_message = messages_to_analyze{idx};

        % Initialize variable to track if the message is similar
        is_similar = false;

        % Compare the input message with each message in the training dataset
        for i = 1:num_messages
            % Tokenize each training message (remove punctuation before tokenizing)
            training_message_cleaned = regexprep(training_contents{i}, '[^\w\s]', '');  % Remove punctuation
            training_tokens = unique(strsplit(lower(training_message_cleaned)));  % Tokenize and make lowercase

            % Generate shingles for the training message
            training_shingles = generate_shingles(training_tokens, shingle_length);

            % Generate MinHash signature for the training message shingles
            training_signature = minhash_signature(training_shingles, num_hashes);

            % Compute the Jaccard similarity between the input and training message
            similarity = jaccard_similarity(input_signature, training_signature);

            % If similarity is greater than 0.5, mark the message as similar and break early
            if similarity > 0.5
                is_similar = true;
                break;  % No need to check further once we find a similar message
            end
        end

        % Display the similarity for the message
        fprintf('Analyzed message: "%s"\n', input_message);
        fprintf('Max Similarity Index: %.4f\n\n', similarity);

        % Categorize the message based on similarity
        if ~is_similar
            % If it's not similar to any training messages, add to not_similar_messages
            not_similar_messages{end+1} = input_message;
        end
    end

    % Display the most not similar messages
    fprintf('Top not similar messages (Similarity <= 0.5):\n');
    for i = 1:length(not_similar_messages)
        disp(not_similar_messages{i});
        fprintf('\n');
    end
end


% Function to generate shingles (n-grams) from tokens
function shingles = generate_shingles(tokens, shingle_length)
    num_tokens = length(tokens);
    shingles = {};
    
    for i = 1:(num_tokens - shingle_length + 1)
        % Create a shingle by joining a subsequence of tokens
        shingle = strjoin(tokens(i:(i + shingle_length - 1)));
        shingles{end + 1} = shingle;
    end
end

% Function to generate MinHash signature for a set of shingles
function signature = minhash_signature(shingles, num_hashes)
    signature = inf(1, num_hashes); % Initialize signature array with large values

    % Generate the signature using hash functions
    for i = 1:num_hashes
        min_hash = inf;  % Start with a large value for the min_hash

        % Apply the hash function to each shingle
        for j = 1:length(shingles)
            hash_val = hash_function(shingles{j}, i); % Apply a different seed for each hash
            min_hash = min(min_hash, hash_val);  % Keep track of the minimum hash value
        end

        % Store the minimum hash value for this hash function
        signature(i) = min_hash; % Ensure a scalar value is assigned
    end
end

% Hash function (MD5 based) to hash the tokens with a given seed
function hash_val = hash_function(token, seed)
    % Convert the token and seed to a string and hash it
    hash_input = strcat(num2str(seed), token);
    hash_output = java.security.MessageDigest.getInstance('MD5');
    hash_output.update(uint8(hash_input), 0, length(hash_input));
    hash_bytes = hash_output.digest();

    % Convert the hash to a large integer (ensuring it's a scalar value)
    hash_val = typecast(uint8(hash_bytes), 'uint32');
    hash_val = hash_val(1); % Ensure we are only taking the first element if it's an array
end

% Function to compute the Jaccard similarity from two MinHash signatures
function similarity = jaccard_similarity(signature1, signature2)
    % Compare the signatures by counting the number of matches
    similarity = sum(signature1 == signature2) / length(signature1);
end
