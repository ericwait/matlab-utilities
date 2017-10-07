function [contrastImage,signalImage,noiseImage,signalMask] = SeperateSignals(imSinglePos)%,thrshAlpha)
signalImage = cell(size(imSinglePos));
noiseImage = cell(size(imSinglePos));

signalMask = cell(size(imSinglePos));
contrastImage = cell(size(imSinglePos));
for i=1:length(signalMask)
    signalMask{i} = false(size(imSinglePos{i}));
    contrastImage{i} = zeros(size(imSinglePos{i}),'like',imSinglePos{i});
end

prgs = Utils.CmdlnProgress(length(imSinglePos),true,'Making Signal and Noise Model Images');
for signalChan=1:length(imSinglePos)
    curSignal = imSinglePos{signalChan};
    curCon = zeros(size(curSignal),'like',curSignal);
    for responceChan=1:size(curSignal,4)
        responceIm = curSignal(:,:,:,responceChan,1);
        curCon(:,:,:,responceChan) = ImProc.ContrastEnhancement(responceIm,[75,75,20],[3,3,3]);
    end
    contrastImage{signalChan} = curCon;
    mask = curCon>0.02;
    signalMask{signalChan} = mask;
    signalIm = curCon;
    signalIm(~mask) = 0;
    signalImage{signalChan} = signalIm;
    noiseIm = curCon;
    noiseIm(mask) = 0;
    noiseImage{signalChan} = noiseIm;
    
    prgs.PrintProgress(signalChan);
end
prgs.ClearProgress(true);

end
