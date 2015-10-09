function newThresh = BackgroundThresh(counts, binCenters, thresh, noiseMaxStd, maxIter)
% Assume that binCenters are ordered lowest to largest

if (~exist('noiseMaxStd','var') || isempty(noiseMaxStd))
    noiseMaxStd = 2;
end

if (~exist('maxIter','var') || isempty(maxIter))
    maxIter = 20;
end

curThresh = 0;
curIter = 0;

while (thresh~=curThresh && curIter<maxIter)
    curThresh = thresh;
    
    backgroundBins = binCenters<curThresh;
    N = sum(counts(backgroundBins));
    
    mu = sum(counts(backgroundBins) .* binCenters(backgroundBins)) / N;
    
    muSub = double(binCenters(backgroundBins)) - mu;
    muSubSq = muSub.^2;
    sm = sum(counts(backgroundBins) .* muSubSq);
    sig = sqrt(sm / (N-1));
    
    thresh = mu + noiseMaxStd*sig;
    
    curIter = curIter +1;
end

newThresh = thresh;
end

