function [valueQQave, freq_profile] = QvsQ(UA, UB, params)
% QvsQ simulates repeated play of a two-player game where both players use 
% Q-learning with softmax exploration to update their action values.
%
% INPUTS:
%   UA, UB  : Payoff matrices for Player A and Player B, respectively.
%   params  : Struct containing simulation parameters:
%       - num_iter : Number of iterations (rounds) per trial
%       - num_trial: Number of repeated independent trials
%       - alpha    : Learning rate for Q-value updates
%       - gamma    : Discount factor applied to rewards
%       - tau      : Temperature parameter for softmax action selection
%       - Q_init   : Initial Q-value assigned to all actions
%
% OUTPUTS:
%   valueQQave   : Average discounted payoff vector [Player A, Player B]
%                  across all trials
%   freq_profile : Average empirical joint action frequency distribution 
%                  over time (num_iter x 4 matrix)

% Initialize accumulators for average values and frequencies
valueQQave = zeros(1,2);
freq_profile = zeros(params.num_iter,4);

% Repeat simulation across multiple trials
for kk = 1:params.num_trial
    
    % Initialize Q-values for both players
    QA = params.Q_init*ones(2,1); 
    QB = params.Q_init*ones(2,1);
    
    % Track joint action counts and frequencies over iterations
    count = zeros(params.num_iter,4); 
    freq  = zeros(params.num_iter,4);
    
    % Track cumulative discounted payoffs in this trial
    valueQQ = zeros(1,2);

    % Loop over iterations (rounds of play)
    for k = 1:params.num_iter
        
        % Compute action probabilities for both players
        br1 = exp(QA/params.tau) / sum(exp(QA/params.tau));
        br2 = exp(QB/params.tau) / sum(exp(QB/params.tau));

        % Select actions stochastically according to probabilities
        aa = chooseAction(br1); 
        bb = chooseAction(br2);

        % Update Q-values using standard Q-learning rule
        QA(aa) = QA(aa) + params.alpha * (UA(aa,bb) - QA(aa));
        QB(bb) = QB(bb) + params.alpha * (UB(aa,bb) - QB(bb));

        % Encode joint action (aa,bb) into an index (1–4)
        idx = (aa-1)*2 + bb;
        
        % Update joint action counts and running frequencies
        count(k,idx) = count(k,idx) + 1;
        freq(k,:)    = sum(count(1:k,:),1) / k;

        % Update cumulative discounted payoffs for this trial
        valueQQ = valueQQ + params.gamma^k * [UA(aa,bb), UB(aa,bb)];
    end
    
    % Accumulate trial results into averages
    valueQQave   = valueQQave + valueQQ;
    freq_profile = freq_profile + freq;
end

% Normalize averages across all trials
valueQQave   = valueQQave / params.num_trial;
freq_profile = freq_profile / params.num_trial;
end
