function [ annotationNew ] = GT_Molina2OUR(fileName)
%GT_MOLINA2OUR %transfer dataset from Molina2014 to our annotation data format
%   Input:
%   @fileName: the ground truth file name from Molina2014.
%   Output:
%   @annotationNew: the our ground truth format. [start:pitch:duration]

    annotation = csvread(fileName);

    annotationNew = zeros(size(annotation));
    

    for i = 1:size(annotationNew,1)
       annotationNew(i,1) =  annotation(i,1);
       annotationNew(i,2) =  annotation(i,3);
       annotationNew(i,3) =  annotation(i,2) - annotation(i,1);
    end

end

