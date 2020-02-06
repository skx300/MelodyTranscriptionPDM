function [Beta] = Backward_multivariate(O, pie , B, A, N, T, po)

    %%
    %% Author : Suryansh Kumar  
    %% Supervised by: Dr. Dizan Vasquez (e-Motion Group, INRIA-Rhone Alpes Grenoble) 
    %%

    Beta = zeros(N,T);


    for i = 1:N
        Beta(i,T)=po(T,1);
    end


    for t = T-1:-1:1
        for i=1:N
            sumi = 0.0;
            for j = 1:N
            sumi = sumi + A(i,j)*(gaussian_multivariate(O(t+1,:), B(j, 1).pdf, B(j, 2).pdf ))*Beta(j, t+1);
            end       
            Beta(i,t) = sumi*po(t,1);
        end
    end


end
