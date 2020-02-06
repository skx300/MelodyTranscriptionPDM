function [ decodedSeqOutput ] = TransPartToSteady( decodedSeq )
%TRANSPARTTOSTEADY Merges the corresponding transition-up or transition-down states for each
%steady state in backward and forward direction.
%   Input
%   @decodedSeq: the HMM decoded sequences.
%   Output
%   @decodedSeqOutput: the output sequences.

    decodedSeqOutput = decodedSeq;
    decodedSeqSteady = decodedSeq;
    %get the steady state
    for i = 1:size(decodedSeqSteady,2)
        decodedSeqSteady(decodedSeqSteady(:,i)-floor(decodedSeqSteady(:,i)) ~= 0,i) = 0;
    end

    for columnN = 1:size(decodedSeqOutput,2)
        NumExpanBackward = 1;
        NumExpanFordward = 1;
        for i = 1:size(decodedSeqOutput,1)
            if(decodedSeqSteady(i,columnN)~=0)
                temp = decodedSeqSteady(i,columnN);

                %check backward
                while (i-NumExpanBackward > 0) && (round(decodedSeqOutput(i-NumExpanBackward,columnN)) == temp)
                    decodedSeqOutput(i-NumExpanBackward,columnN) = temp; 
                    NumExpanBackward = NumExpanBackward + 1;
                end
                NumExpanBackward = 1;

                %check forward
                while (i+NumExpanFordward<= size(decodedSeqOutput,1)) && (round(decodedSeqOutput(i+NumExpanFordward,columnN)) == temp)
                    decodedSeqOutput(i+NumExpanFordward,columnN) = temp; 
                    NumExpanFordward = NumExpanFordward + 1;
                end
                NumExpanFordward = 1;        
            end
        end
    end

end

