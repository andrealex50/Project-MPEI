function Test_minHash()

    addpath('C:\Users\pcdoa\Project-MPEI');
    addpath('C:\Users\pcdoa\Project-MPEI\DataSets\');

    mensagens = {
        "Ill save you the trouble sister. Here comes a big ol fuck France block coming your way here on the twitter."
        " Im dead serious.Real athletes never cheat don't even have the appearance of at his level. Fuck him dude seriously  I think he did"
        "nigga u geigh lmao! fuck yo finals beeeeeitch"
        "mangualde viseu"
    };

    caminho_json_treino = 'DataSets/aggressive_texts.json';
    disp("---MinHash---");
    % (1) MinHash
    mensagens_sem_similaridade = minHash(mensagens, caminho_json_treino);

    disp('Mensagens sem similaridade');
    for i = 1:length(mensagens_sem_similaridade)
        disp(mensagens_sem_similaridade{i});
    end
end
