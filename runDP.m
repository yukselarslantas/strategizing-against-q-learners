function [V, policy, error] = runDP(UA, UB, params)
% runDP performs dynamic programming (DP) over a finite horizon for a
% two-player repeated game setting. One player is modeled using quantized 
% Q-value states, and the other player’s responses are captured via softmax.
%
% INPUTS:
%   UA, UB  : Payoff matrices for Player A and Player B, respectively.
%   params  : Struct containing DP parameters:
%       - H      : Horizon length
%       - n1,n2  : Number of quantization levels for Player A and B states
%       - Qmax1, Qmin1 : Quantization range for Player A’s Q-values
%       - Qmax2, Qmin2 : Quantization range for Player B’s Q-values
%       - alpha  : Update step size for Q-learning dynamics
%       - gamma  : Discount factor
%       - tau    : Temperature parameter for softmax
%
% OUTPUTS:
%   V       : Value function over horizon and state space (H+1 x n1 x n2)
%   policy  : Optimal policy for Player A at each state and horizon
%   error   : Convergence error per DP step

% Initialize storage for value function, policy, and DP errors
V      = zeros(params.H+1, params.n1, params.n2);
policy = zeros(params.n1, params.n2, params.H+1);
error  = zeros(1, params.H);

% Backward induction over the horizon
for h = params.H:-1:1
    for si = 1:params.n1
        for sj = 1:params.n2
            
            % Map discrete state indices back to quantized Q-values
            q_hat1 = inverse_quantizer(si, params.Qmax1, params.Qmin1, params.n1);
            q_hat2 = inverse_quantizer(sj, params.Qmax2, params.Qmin2, params.n2);

            % Compute next states for all action profiles:
            % CC = (A cooperates, B cooperates), CD, DC, DD
            s_nextCC = [quantizer(q_hat1 + params.alpha*(UB(1,1)-q_hat1), ...
                                  params.Qmax1, params.Qmin1, params.n1), ...
                        quantizer(q_hat2, ...
                                  params.Qmax2, params.Qmin2, params.n2)];

            s_nextCD = [quantizer(q_hat1, ...
                                  params.Qmax1, params.Qmin1, params.n1), ...
                        quantizer(q_hat2 + params.alpha*(UB(1,2)-q_hat2), ...
                                  params.Qmax2, params.Qmin2, params.n2)];

            s_nextDC = [quantizer(q_hat1 + params.alpha*(UB(2,1)-q_hat1), ...
                                  params.Qmax1, params.Qmin1, params.n1), ...
                        quantizer(q_hat2, ...
                                  params.Qmax2, params.Qmin2, params.n2)];

            s_nextDD = [quantizer(q_hat1, ...
                                  params.Qmax1, params.Qmin1, params.n1), ...
                        quantizer(q_hat2 + params.alpha*(UB(2,2)-q_hat2), ...
                                  params.Qmax2, params.Qmin2, params.n2)];

            % Compute softmax response probabilities (Boltzmann exploration)
            Bres = exp([q_hat1; q_hat2]/params.tau);
            Bres = Bres / sum(Bres);

            % Look up continuation values (future rewards) for each action profile
            VV = [V(h+1, s_nextCC(1), s_nextCC(2)), V(h+1, s_nextCD(1), s_nextCD(2)); ...
                  V(h+1, s_nextDC(1), s_nextDC(2)), V(h+1, s_nextDD(1), s_nextDD(2))];

            % Compute Q-values as immediate reward + discounted future value
            QQ = UA*Bres + params.gamma*VV*Bres;

            % Select action that maximizes Player A’s expected payoff
            if QQ(1) >= QQ(2)
                V(h,si,sj)    = QQ(1); 
                policy(si,sj,h) = 1;   % Action 1 is optimal
            else
                V(h,si,sj)    = QQ(2); 
                policy(si,sj,h) = 2;   % Action 2 is optimal
            end

            % Track DP error as maximum change between consecutive horizons
            error(params.H-h+1) = max(error(params.H-h+1), abs(V(h,si,sj)-V(h+1,si,sj)));
        end
    end
end
end
