%% Main Script: Q-Learner vs Dynamic Programming (DP) in a 2x2 Game
%
% Description:
%   This script simulates and compares two learning dynamics in a 
%   2-player 2x2 game (e.g., Prisoner's Dilemma):
%       1. Q-Learner vs Q-Learner (both players use Q-learning with 
%          softmax exploration)
%       2. Q-Learner vs Strategic Agent (Dynamic Programming-based optimal policy)
%
%   The script performs the following steps:
%       - Defines the game payoff matrices UA and UB
%       - Sets simulation parameters (quantization, horizon, discount, etc.)
%       - Computes empirical frequencies and discounted values for Q-learning
%       - Solves the DP problem to obtain the optimal policy
%       - Simulates interactions between Q-learner and DP agent
%       - Plots empirical frequencies and DP policy/value surfaces
%       - Saves results in a .mat file
%
%   Parameters can be easily modified to simulate different games or 
%   learning settings.
%
% Dependencies:
%   - getGame.m
%   - QvsQ.m
%   - QvsDP.m
%   - runDP.m
%   - chooseAction.m
%   - quantizer.m / inverse_quantizer.m
%
% Author: Yüksel Arslantaş
% Date:   2025-10-07
% -------------------------------------------------------------------------

clc; clear;

% =========================================================================
% getGame - Load payoff matrices and result file name for selected 2x2 game
% =========================================================================
% Inputs:
%   gameType : string specifying the type of game to load. Options:
%       - 'pd' : Prisoner’s Dilemma
%       - 'mp' : Matching Pennies
%
% Outputs:
%   UA       : 2x2 payoff matrix for Player A
%   UB       : 2x2 payoff matrix for Player B
%   saveFile : String filename to use when saving results

[UA, UB, saveFile] = getGame('pd');

% -------------------------------
% Simulation parameters
% -------------------------------
params.n1 = 100;         % quantization levels for DP
params.n2 = 100;
params.H = 20;           % DP horizon
params.gamma = 0.8;      % discount factor
params.alpha = 0.1;      % step size
params.tau = 0.01;       % temperature parameter
params.num_iter = 1e3;
params.num_trial = 100;
params.Q_init = 0;       % initial Q-values

% -------------------------------
% Quantization bounds
% -------------------------------
params.Qmax1 = max(UB(:,1)); params.Qmin1 = min(UB(:,1));
params.Qmax2 = max(UB(:,2)); params.Qmin2 = min(UB(:,2));

% -------------------------------
% Q-Learner vs Q-Learner
% -------------------------------
[valueQQave, freq_profile] = QvsQ(UA, UB, params);

% Plot QvsQ empirical averages
figure;
semilogx(1:params.num_iter, freq_profile','LineWidth',2)
legend('AA','AB','BA','BB','Orientation','horizontal','Location','northwest')
xlabel('Iteration'); ylabel('Empirical Averages')
title('Q-Learner vs Q-Learner'); grid on

% -------------------------------
% Dynamic Programming: compute optimal policy
% -------------------------------
[V, policy, error] = runDP(UA, UB, params);

% -------------------------------
% Q-Learner vs DP
% -------------------------------
[valueDPQave, freq_profileDP] = QvsDP(UA, UB, V, policy, params);

% Compute discounted values
QQvalue = (1-params.gamma) * valueQQave;
DPQvalue = (1-params.gamma) * valueDPQave;

disp('QQvalue:'); disp(QQvalue)
disp('DPQvalue:'); disp(DPQvalue)

% Plot QvsDP empirical averages
figure;
semilogx(1:params.num_iter, freq_profileDP','LineWidth',2)
legend('AA','AB','BA','BB','Orientation','horizontal','Location','northwest')
xlabel('Iteration'); ylabel('Empirical Averages')
title('Q-Learner vs Strategic Agent'); grid on

% Save results
save(saveFile, 'QQvalue', 'DPQvalue', 'valueQQave', 'valueDPQave', ...
    'freq_profile', 'freq_profileDP', 'V', 'policy', 'error');