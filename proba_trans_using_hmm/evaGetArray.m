function [ fwArray ,tuningChose] = evaGetArray( fwCell )
%EVAGETARRAY Returns the best evaluation measure based on which tuning
%sequence
%   Input:
%   @fwCell: the measure in cell.
%   Output:
%   @fwArray: the measure in array.
%   @tuningChose: the corresponding choose which tuning fixed sequence.

    fwArray = zeros(size(fwCell,1),3);
    tuningChose = zeros(size(fwCell,1),1);
    for iii = 1:size(fwCell,1) 
        %choose which tuning sequence
        [~,tuningChose(iii)] = max(fwCell{iii,1}(end,:));
        fwArray(iii,:) = fwCell{iii,1}(:,tuningChose(iii))'; 
    end

end

