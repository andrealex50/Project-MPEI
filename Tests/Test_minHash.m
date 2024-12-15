function Test_minHash()

    addpath('C:\Users\pcdoa\Project-MPEI');
    addpath('C:\Users\pcdoa\Project-MPEI\DataSets\');

    mensagens = {
        "Faggot fag fag. Gay sex man blowjob. Calm down."
        "Dude, that would be super creepy, no doubt."
        "HOLY SHIT. Screw that band."
        "Today is a beautiful day"
    };

    caminho_json_treino = 'DataSets/aggressive_texts.json';
    disp("---MinHash---");
    % (1) MinHash
    mensagens_sem_similaridade = minHash(mensagens, caminho_json_treino);

    for i = 1:length(mensagens_sem_similaridade)
        disp(mensagens_sem_similaridade{i});
    end
end