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
        case 'anti-coordination'
            UA = [0.1,0.5;0.4,0.1];
            UB = [0.1,0.4;0.5,0.1];
            saveFile = 'antiCoordination.mat';
        case 'coordination'
            UA = [0.5,0.1;0.1,0.4];
            UB = [0.5,0.1;0.1,0.4];
            saveFile = 'coordination.mat';
        case 'cyclic'
            UA = [0.5,0.1;0.1,0.4];
            UB = [-0.5,0.1;0.1,-0.4];
            saveFile = 'cyclic.mat';
        otherwise
            error('Unknown game type')
    end
end
