function [outputDistance] = EditDistance(vector1,vector2)
%EDITDISTANCE Return the edit distance for two vectors
%Input
%@vector1: the first vector, could be integers, floatings, characters
%@vector2: the second vector
%Output
%@outputDistance: the edit distance value

    n = length(vector1);
    m = length(vector2);

    d = zeros(n+1,m+1);
    d(2:end,1) = [1:n];
    d(1,2:end) = [1:m];
    for i = 2:n+1
        for j = 2:m+1
            temp1 = d(i-1,j)+1; %deletion based on vector1
            temp2 = d(i,j-1)+1; %insertion based on vector1
            if vector1(i-1) == vector2(j-1)
                temp3 = d(i-1,j-1) + 0;
            else
                temp3 = d(i-1,j-1) + 1; %substitution based on vector1
            end
            d(i,j) = min([temp1,temp2,temp3]);
        end
    end
    
    outputDistance = d(end,end);
    
end

