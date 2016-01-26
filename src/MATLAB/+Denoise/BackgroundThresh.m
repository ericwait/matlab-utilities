function thresh = BackgroundThresh(counts, minAcceleration)
% Assume that binCenters are ordered lowest to largest

if (~exist('minAcceleration','var') || isempty(minAcceleration))
    minAcceleration = 10^-5;
end

counts = counts/sum(counts);
starts = find(counts>0,1);
countsDiff = ( counts(starts+1:end)-counts(starts:end-1) );
countsDiff2 = ( countsDiff(starts+1:end)-countsDiff(starts:end-1) );

thresh = find(abs(countsDiff2)<minAcceleration,1) + starts;

% while (thresh~=curThresh && curIter<maxIter)
%     curThresh = thresh;
%     
%     backgroundBins = binCenters<curThresh;
%     foregroundBins = binCenters>curThresh;
%     
%     backN = sum(counts(backgroundBins));
%     backMu = sum(counts(backgroundBins) .* binCenters(backgroundBins)) / backN;
%     foreN = sum(counts(foregroundBins));
%     foreMu = sum(counts(foregroundBins) .* binCenters(foregroundBins)) / foreN;
%     
%     muSub = double(binCenters(backgroundBins)) - backMu;
%     muSubSq = muSub.^2;
%     sm = sum(counts(backgroundBins) .* muSubSq);
%     sig = sqrt(sm / (backN-1));
%     
%     thresh = foreMu - noiseMaxStd*sig;
%     
%     curIter = curIter +1;
% end
% 
% newThresh = thresh;
end

