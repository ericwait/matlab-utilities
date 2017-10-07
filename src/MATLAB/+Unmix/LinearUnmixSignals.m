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

[mixingMatrix, unmixingMatrix, errorMask] = Unmix.CreateFactors(signalImage,zeroChannels,showPlots,'Signal Only Single Positives');
if (showPlots)
    imSPsigUn = cell(length(imSinglePos),1);
    prgs = Utils.CmdlnProgress(length(imSinglePos),true,'Unmixing Single Pos');
    for i=1:length(imSinglePos)
        curIm = imSinglePos{i};
        curIm = curIm(:,:,:,:,1);
        imSPsigUn{i} = ImProc.LinearUnmixing(curIm,unmixingMatrix);
        prgs.PrintProgress(i);
    end
    prgs.ClearProgress(true);
    Unmix.PlotResults(imSPsigUn,'Signal Only Unmixing Factors',[]);
    Unmix.PlotResults(signalImage,'Signal Only Errors',errorMask);
end
end
