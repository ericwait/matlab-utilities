function im = FluorescentBGRemoval(im, bwMask, noiseMaxStd, maxIter)

[~, ~,maxVal] = classBits(im);

if (~exist('noiseMaxStd','var') || isempty(noiseMaxStd))
    noiseMaxStd = 2;
end

if (~exist('maxIter','var') || isempty(maxIter))
    maxIter = 20;
end

if (~exist('bwMask','var') || isempty(bwMask))
    [counts,binCenters] = imhist(im(:));
    thr = graythresh(im(:))*maxVal;
else
    [counts,binCenters] = imhist(im(bwMask));
    thr = graythresh(im(bwMask))*maxVal;
end

thr = BackgroundThresh(counts,binCenters,thr,noiseMaxStd,maxIter);

if (~exist('bwMask','var') || isempty(bwMask))
    im(im<thr) = 0;
else
    im(im(bwMask)<thr) = 0;
end
end