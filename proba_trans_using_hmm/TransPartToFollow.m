function [ decodedSeqNew ] = TransPartToFollow( decodedSeq )
%TransPartToFollow makes the transition part belong to following notes.
%   Input
%   @decodedSeq: the decoded sequence (3 columns).
%   Output
%   @decodedSeqNew: the manipluated sequences.

    index = find(decodedSeq ~= floor(decodedSeq));
    transition = zeros(size(decodedSeq));

    transition(index) = decodedSeq(index);

    decodedSeqNew = decodedSeq;
    reference = [];
    for i = size(transition,1):-1:1
        if i == size(transition,1)
            %make the last frame equals to zero
            decodedSeqNew(i,:) = zeros(1,3);
        else
           if sum(transition(i,:) == zeros(1,3)) == 0  && isempty(reference)
               reference = decodedSeq(i+1,:);
               decodedSeqNew(i,:) = reference;
           elseif sum(transition(i,:) == zeros(1,3)) == 0 && isempty(reference) == 0
               decodedSeqNew(i,:) = reference;
           elseif sum(transition(i,:) == zeros(1,3)) == 3
               reference = [];
           end
        end
    end

end

