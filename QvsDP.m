function [valueDPQave, freq_profileDP] = QvsDP(UA, UB, V, policy, params)
% QvsDP simulates repeated play of a two-player game where:
%   - Player A follows a DP-based optimal policy derived from value function V
%   - Player B uses Q-learning with softmax action selection
%
% INPUTS:
%   UA, UB   : Payoff matrices for Player A and Player B, respectively
%   V        : Value function obtained from dynamic programming
%   policy   : Optimal policy derived from DP for Player A
%   params   : Struct containing simulation parameters:
%       - num_iter  : Number of iterations per trial
%       - num_trial : Number of independent trials (averaging)
%       - Q_init    : Initial attraction/Q-value for Player B
%       - alpha     : Learning rate for Q-learning updates
%       - gamma     : Discount factor
%       - tau       : Softmax temperature (exploration parameter)
%       - Qmax1,Qmin1,n1 : Quantization parameters for Player B's first Q
%       - Qmax2,Qmin2,n2 : Quantization parameters for Player B's second Q
%
% OUTPUTS:
%   valueDPQave   : Average discounted payoff values [PlayerA, PlayerB]
%   freq_profileDP: Average empirical joint action frequencies across trials

% Initialize averages across trials
valueDPQave   = zeros(1,2);
freq_profileDP = zeros(params.num_iter,4);

% Repeat simulation over multiple independent trials
for kk = 1:params.num_trial
    % Initialize Q-values for Player B
    QB = params.Q_init*ones(2,1);
    
    % Storage for joint action counts and frequencies
    count = zeros(params.num_iter,4); 
    freq  = zeros(params.num_iter,4);
    
    % Discounted cumulative payoff values for this trial
    valueDPQ = zeros(1,2);

    % Iterate the repeated game
    for k = 1:params.num_iter
        % Quantize Player B's Q-values into discrete states
        s1 = quantizer(QB(1), params.Qmax1, params.Qmin1, params.n1);
        s2 = quantizer(QB(2), params.Qmax2, params.Qmin2, params.n2);
        
        % Player A: chooses action from DP-derived policy
        aa = policy(s1, s2, 1);

        % Player B: chooses action probabilistically using softmax(QB)
        br2 = exp(QB/params.tau)/sum(exp(QB/params.tau));
        bb = chooseAction(br2);

        % Player B: update Q-value for chosen action
        QB(bb) = QB(bb) + params.alpha*(UB(aa,bb)-QB(bb));

        % Track action pair frequency
        idx = (aa-1)*2 + bb; 
        count(k,idx) = count(k,idx)+1;
        freq(k,:) = sum(count(1:k,:),1)/k;

        % Update discounted payoff values
        valueDPQ = valueDPQ + params.gamma^k * [UA(aa,bb), UB(aa,bb)];
    end

    % Accumulate results across trials
    valueDPQave   = valueDPQave + valueDPQ;
    freq_profileDP = freq_profileDP + freq;
end

% Average across trials
valueDPQave   = valueDPQave / params.num_trial;
freq_profileDP = freq_profileDP / params.num_trial;
end
