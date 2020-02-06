function [alpha, po] = Forward_multivariate(O, pie, B, A, N, T)




%%
%% Author : Suryansh Kumar
%% Supervised by: Dr. Dizan Vasquez (e-Motion Group, INRIA-Rhone Alpes Grenoble) 
%%


alpha = zeros(N, T);

po = zeros(T,1);     % needed in backward algorithm
norm_po = zeros(T,1); % normalization factor




    for i = 1:N
       alpha(i,1) = pie(i)*gaussian_multivariate(O(1,:), B(i,1).pdf , B(i,2).pdf);   %  Storing the alpha for T = 1 , gaussian of (X, mean, sigma)
       norm_po(1,1) = norm_po(1,1) + alpha(i,1);
    end
    
    po(1,1) = 1.0/norm_po(1,1);
    
    alpha(:,1) = alpha(:,1)*po(1,1);    % normalising for the first observation
    
    
    
% For Rest of the T
    for t = 2:T
       
        for j = 1:N
            
            sumi =0.0;
            for i = 1:N
               sumi = sumi + alpha(i, t-1)*A(i,j);      % Mutiplying the transition part, over each alpha of the previous time.
            end
            
            alpha(j,t) = sumi*gaussian_multivariate(O(t,:), B(j, 1).pdf, B(j, 2).pdf);  % multiplying with the belief
            norm_po(t,1) = norm_po(t,1) + alpha(j,t);   % storing the summation value to normalise afterwards.
        end
        
       po(t, 1) = 1.0/norm_po(t,1); 
       
       alpha(:,t) = alpha(:,t)*po(t,1);

    end
        
   
    
end
