function [UA, UB, saveFile] = getGame(gameType)
    switch lower(gameType)
        case 'pd'
            UA = [0.5,-1; 1,-0.5];
            UB = [0.5,1; -1,-0.5];
            saveFile = 'PD.mat';
        case 'mp'
            UA = [1, -1; -1, 1];
            UB = -UA;
            saveFile = 'MP.mat';
        otherwise
            error('Unknown game type')
    end
end
