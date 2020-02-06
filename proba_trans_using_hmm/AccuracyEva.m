function [ accuracy ] = AccuracyEva(input,groundTruth)
%AccuracyEva return the frame-wise accuracy
%Input:
%@input: input column vector or matrix.
%@groundTruth: the ground truth vector, should have the same number of columns as input.
%Output:
%@accuracy: the scaler or vector indicates the accuracy for each column.
    
    numColInput = size(input,2);
    if numColInput == 1
%         accuracy = length(find((input == groundTruth)==1))/length(input);
        %the raw pitch accuracy of voiced frames
        accuracy = length(find((input(input~=0) == groundTruth(input~=0))==1))/length(input(input~=0));
    else
        accuracy = zeros(1,numColInput);
        for i = 1:numColInput
%             accuracy(i) = length(find((input(:,i) == groundTruth)==1))/length(input(:,i));
        %the raw pitch accuracy of voiced frames
            accuracy(i) = length(find((input(input(:,i)~=0,i) == groundTruth(input(:,i)~=0))==1))/length(input(input(:,i)~=0,i));
        end
    end

end

