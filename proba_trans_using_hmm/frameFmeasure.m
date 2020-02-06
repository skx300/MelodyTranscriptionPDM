function [outputStat] = frameFmeasure( decodedSeq,stateGroundTruth )
%FRAMEFMEASURE returns the frame-wise precison, recall and f-measure.
%Unvoiced is indicates as 0 (negative). 
%   Input:
%   @decodedSeq: transcribed sequence. Could be matrix whose column
%   indicate one transcribed sequence.
%   @stateGroundTruth: the ground truth state sequence.
%   Output:
%   @outputStat: [P;R;F] format.

    numColdecodedSeq = size(decodedSeq,2);
    
    numTP = zeros(1,numColdecodedSeq);
    TPFP = zeros(1,numColdecodedSeq);
    TPFN = zeros(1,numColdecodedSeq);
    
    for i = 1:numColdecodedSeq
        %true positives, i.e. the frames that the pitch is correctly
        %transcribed and voiced.
        numTP(i) = length(find((decodedSeq(decodedSeq(:,i) ~= 0,i) == stateGroundTruth(decodedSeq(:,i) ~= 0)) == 1));
        %frames have pitch transcription and voiced estimated.
        TPFP(i) = length((decodedSeq(decodedSeq(:,i) ~= 0,i)));
        %frames have ground truth pitch and voiced.
        TPFN(i) = length(find(stateGroundTruth~=0));       
    end
        P = numTP ./TPFP;
        R = numTP ./TPFN;
        F = 2.*P.*R./(P+R);
        
    outputStat = [P;R;F];
end

