function [ mixingMatrix, unmixingMatrix ] = linearUnmixSignals(showPlots,zeroChannels,imSinglePos)
%LINEARUNMIXSIGNALS Summary of this function goes here
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
    imSinglePos = openSinglePosImages();
    if (isempty(imSinglePos))
        return;
    end
end

if (showPlots)
    plotResults(imSinglePos,'Orginal Single Positives',[]);
end

[contrastImage,signalImage,noiseImage,signalMask] = seperateSignals(imSinglePos);%,0.6);

if (showPlots)
    plotResults(contrastImage,'Contrast Enhanced',[]);
    plotResults(signalImage,'Signal Only',[]);
    plotResults(noiseImage,'Noise Only',[]);
    plotResults(signalMask,'Mask',[]);
end

[orgMixing, orgUnmixing, errorMask] = createFactors(imSinglePos,zeroChannels,showPlots,'Orginal Single Positives');
if (showPlots)
    imSPorgUn = zeros(size(imSinglePos),'single');
    for i=1:size(imSinglePos,5)
        imSPorgUn(:,:,:,:,i) = CudaMex('LinearUnmixing',imSinglePos(:,:,:,:,i),orgUnmixing);
    end
    imSPorgUn(imSPorgUn<0) = 0;
    plotResults(imSPorgUn,'Orginal Unmixed',[]);
    plotResults(imSinglePos,'Orginal errors',errorMask);
end

[mixingMatrix, unmixingMatrix, errorMask] = createFactors(signalImage,zeroChannels,showPlots,'Signal Only Single Positives');
if (showPlots)
    imSPsigUn = zeros(size(imSinglePos),'single');
    for i=1:size(imSinglePos,5)
        imSPsigUn(:,:,:,:,i) = CudaMex('LinearUnmixing',imSinglePos(:,:,:,:,i),unmixingMatrix);
    end
    imSPsigUn(imSPsigUn<0) = 0;
    plotResults(imSPsigUn,'Signal Only Unmixing Factors',[]);
    plotResults(signalImage,'Signal Only Errors',errorMask);
end

orgMixing
mixingMatrix

orgMixing-mixingMatrix
end
