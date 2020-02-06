function [currentState, logP] = hmmviterbiLuwei(seq,tr,e,varargin)
%HMMVITERBI amend from the built-in hmmviterbi.m 


numStates = size(tr,1);
customStatenames = false;

% work in log space to avoid numerical issues
L = length(seq);
logTR = log(tr);
logE = log(e);

% allocate space
pTR = zeros(numStates,L);
% assumption is that model is in state 1 at step 0
v = -Inf(numStates,1);
v(1,1) = 0;
vOld = v;

% loop through the model
for count = 1:L
    for state = 1:numStates
        % for each state we calculate
        % v(state) = e(state,seq(count))* max_k(vOld(:)*tr(k,state));
        bestVal = -inf;
        bestPTR = 0;
        % use a loop to avoid lots of calls to max
        for inner = 1:numStates 
            val = vOld(inner) + logTR(inner,state);
%             disp(['State:',num2str(state),'inner:',num2str(inner),'',num2str(logTR(inner,state))]);
%             val = vOld(inner) + log(normpdf(state,tr(inner,1),tr(inner,2)));           
            if val > bestVal
                bestVal = val;
                bestPTR = inner;
            end
        end
        % save the best transition information for later backtracking
        pTR(state,count) = bestPTR;
        % update v
        v(state) = logE(state,count) + bestVal;
    end
    vOld = v;
end

% decide which of the final states is post probable
[logP, finalState] = max(v);

% Now back trace through the model
currentState(L) = finalState;
for count = L-1:-1:1
    currentState(count) = pTR(currentState(count+1),count+1);
    if currentState(count) == 0
        error(message('stats:hmmviterbi:ZeroTransitionProbability', currentState( count + 1 )));
    end
end
if customStatenames
    currentState = reshape(statenames(currentState),1,L);
end


