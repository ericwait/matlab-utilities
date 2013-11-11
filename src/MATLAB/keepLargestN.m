function im = keepLargestN(imIn,N)

cc = bwconncomp(imIn,6);

maxIdx = zeros(1,N);
maxVol = zeros(1,N);
for i=1:length(cc.PixelIdxList)
    maxVolT = [maxVol length(cc.PixelIdxList{i})];
    maxIdxT = [maxIdx i];
    [sortVols, sortIdx] = sort(maxVolT);
    maxVol = sortVols(2:N+1);
    maxIdx = maxIdxT(sortIdx(2:N+1));
end

im = zeros(cc.ImageSize,'uint8');
for i=1:N
    im(cc.PixelIdxList{maxIdx(i)}) = 255;
end
end