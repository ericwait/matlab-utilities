function [contrastImage,signalImage,noiseImage,signalMask] = seperateSignals(imSinglePos)%,thrshAlpha)
signalMask = false(size(imSinglePos));
contrastImage = zeros(size(imSinglePos),'like',imSinglePos);

for signalChan=1:size(imSinglePos,5)
    for responceChan=1:size(imSinglePos,4)
        contrastImage(:,:,:,responceChan,signalChan) = max(0,CudaMex('ContrastEnhancement',imSinglePos(:,:,:,responceChan,signalChan),[250,250,75],[3,3,3]));
    end
    sigIm = contrastImage(:,:,:,signalChan,signalChan);
    %thrs = graythresh(sigIm(:))
    tmp = sigIm>0;
    signalMask(:,:,:,:,signalChan) = repmat(tmp,1,1,1,size(imSinglePos,4));
end

signalImage = contrastImage;
signalImage(~signalMask) = 0;
noiseImage = contrastImage;
noiseImage(signalMask) = 0;
end
