% calculate the reduced image dimensions for a given reduction and stepSize
function [imData,reduction] = reduce(reduction,imData,stepSize)

if (~exist('stepSize','var') || isempty(stepSize))
    stepSize = 0.1;
end

reduction = [reduction(1:2) + stepSize, 1];

imData.XDimension = floor(imData.XDimension/reduction(2));
imData.YDimension = floor(imData.YDimension/reduction(1));

end
