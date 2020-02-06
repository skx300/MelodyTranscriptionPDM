function [ error ] = confidenceIntervalError( x )
%CONFIDENCEINTERVAL calcualte confidence interval error
%input
%@x: the input vector or matrix. If it is matrix, the error will calcualted
%for each column vector
%@error: the error for confidence interval mean(x) +- error.

    %99%: z = 2.58; 95%: z = 1.96; 90%: z = 1.64
    
    z = 1.96;
    n = size(x,1);
    
    error = z*std(x)/sqrt(n);

end

