% calculate the reduced image dimensions for a given reduction and stepSize
function [reduction] = reduce(reduction,stepSize)

if (~exist('stepSize','var') || isempty(stepSize))
    stepSize = 1;
end

reduction = [reduction(1:2) + stepSize, 1];
end
