function [mixingMatrix, unmixingMatrix, errorMask] = createFactors(images,zeroChannels,showPlots,figureName)
%% create factors
minVal = [];
maxVal = [];

mixingMatrix = zeros(size(images,4),size(images,5),2);
thrs = zeros(size(images,4),size(images,5));
errorMask = false(size(images,1)*size(images,2),size(images,4),size(images,5));

if (showPlots)
    figure('Name',figureName,'NumberTitle','off');
    set(gcf,'Units','normalize','Position',[0 0 1 1]);
end

for signalChan=1:size(images,5)
    imSignal = images(:,:,:,signalChan,signalChan);
    if (~isempty(zeroChannels) && ~any(zeroChannels==signalChan))
        imSignal(:,:,:,zeroChannels) = zeros(size(imSignal(:,:,:,zeroChannels)),'like',imSignal);
    end
    imSiganl = [imSignal(:) ones(length(imSignal(:)),1)];
    for responceChan=1:size(images,4)
        imResponce = images(:,:,:,responceChan,signalChan);
        if (responceChan==signalChan)
            mixingMatrix(responceChan,signalChan,:) = [1 0];
        else
            [mixingMatrix(responceChan,signalChan,:), ~] = regress(imResponce(:),imSiganl);
        end
        
        curVar = (imResponce(:)-(mixingMatrix(responceChan,signalChan,1)*imSiganl(:,1))+mixingMatrix(responceChan,signalChan,2)).^2;
        thrs(responceChan,signalChan) = prctile(curVar,95);
        errorMask(:,responceChan,signalChan) = curVar>thrs(responceChan,signalChan);
        inds = find(errorMask(:,responceChan,signalChan));
        
        if (showPlots)
            subplot(size(images,4),size(images,5),responceChan + (signalChan-1)*size(images,4));
            [minVal, maxVal] = plotRegression(imSignal,signalChan,responceChan,thrs(responceChan,signalChan),imSiganl,imResponce,mixingMatrix,minVal,maxVal,inds);
        end
    end
end

if (showPlots)
    drawnow
end

%% calculate unmixing
unmixingMatrix = inv(mixingMatrix(:,:,1));
end
