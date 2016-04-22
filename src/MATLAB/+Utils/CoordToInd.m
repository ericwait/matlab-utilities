% CoordToInd - Convert subscript indices to linear array indices.
% 
% arrayIdx = CoordToInd(arraySize, coords)
function arrayIdx = CoordToInd(arraySize, coords)
    linSize = [1 cumprod(arraySize(1:end-1))];
    arrayIdx = sum((coords-1) .* repmat(linSize, size(coords,1),1), 2) + 1;
end
