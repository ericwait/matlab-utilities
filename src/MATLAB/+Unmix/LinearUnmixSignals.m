function [ mixingMatrix, unmixingMatrix ] = LinearUnmixSignals(showPlots,zeroChannels,imSinglePos)
%[ mixingMatrix, unmixingMatrix ] = Unmix.LinearUnmixSignals(showPlots,zeroChannels,imSinglePos)
%   Detailed explanation goes here

mixingMatrix = [];
unmixingMatrix = [];

if (~exist('showPlots','var') || isempty(showPlots))
    showPlots = 0;
end
if (~exist('zeroChannels','var'))
    zeroChannels = [];
end

if (~exist('imSinglePos','var') || isempty(imSinglePos))
    imSinglePos = Unmix.OpenSinglePosImages();
    if (isempty(imSinglePos))
        return;
    end
end

if (showPlots)
    Unmix.PlotResults(imSinglePos,'Orginal Single Positives',[]);
end

[contrastImage,signalImage,noiseImage,signalMask] = Unmix.SeperateSignals(imSinglePos);%,0.6);

if (showPlots)
    Unmix.PlotResults(contrastImage,'Contrast Enhanced',[]);
    Unmix.PlotResults(signalImage,'Signal Only',[]);
    Unmix.PlotResults(noiseImage,'Noise Only',[]);
    Unmix.PlotResults(signalMask,'Mask',[]);
end

% [orgMixing, orgUnmixing, errorMask] = createFactors(imSinglePos,zeroChannels,showPlots,'Orginal Single Positives');
% if (showPlots)
%     imSPorgUn = zeros(size(imSinglePos),'single');
%     for i=1:size(imSinglePos,5)
%         imSPorgUn(:,:,:,:,i) = CudaMex('LinearUnmixing',imSinglePos(:,:,:,:,i),orgUnmixing);
%     end
%     imSPorgUn(imSPorgUn<0) = 0;
%     plotResults(imSPorgUn,'Orginal Unmixed',[]);
%     plotResults(imSinglePos,'Orginal errors',errorMask);
% end

[mixingMatrix, unmixingMatrix, errorMask] = Unmix.CreateFactors(signalImage,zeroChannels,showPlots,'Signal Only Single Positives');
if (showPlots)
    imSPsigUn = zeros(size(imSinglePos),'single');
    for i=1:size(imSinglePos,5)
        imSPsigUn(:,:,:,:,i) = Cuda.Mex('LinearUnmixing',imSinglePos(:,:,:,:,i),unmixingMatrix);
    end
    imSPsigUn(imSPsigUn<0) = 0;
    Unmix.PlotResults(imSPsigUn,'Signal Only Unmixing Factors',[]);
    Unmix.PlotResults(signalImage,'Signal Only Errors',errorMask);
end

% orgMixing
% mixingMatrix
% 
% orgMixing-mixingMatrix
end
