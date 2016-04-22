% IndToCoord - Convert linear array indices into a list of subscript
% indices.
% 
% coords = IndToCoord(arraySize, arrayIdx)
function coords = IndToCoord(arraySize, arrayIdx)
    coords = zeros(length(arrayIdx),length(arraySize));

    linSize = [1 cumprod(arraySize)];
    partialIdx = arrayIdx;
    for i = length(arraySize):-1:1
        r = rem(partialIdx-1, linSize(i)) + 1;
        q = floor((partialIdx-r) / linSize(i)) + 1;

        coords(:,i) = q;
        partialIdx = r;
    end
end
