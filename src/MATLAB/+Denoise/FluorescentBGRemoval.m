function im = FluorescentBGRemoval(im, bwMask, minAcceleration)
if (~exist('minAcceleration','var') || isempty(minAcceleration))
    minAcceleration = 10^-6;
end

if (~exist('bwMask','var') || isempty(bwMask))
    [counts,binCenters] = imhist(im(:));
else
    [counts,binCenters] = imhist(im(bwMask));
end

counts(1) = 0;
thr = Denoise.BackgroundThresh(counts,minAcceleration);

thr = binCenters(thr);

if (~exist('bwMask','var') || isempty(bwMask))
    im(im<thr) = 0;
else
    im(im(bwMask)<thr) = 0;
end
end