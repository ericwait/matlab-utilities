function [mixingMatrix, unmixingMatrix, errorMask] = CreateFactors(images,zeroChannels,showPlots,figureName)
%% create factors
minVal = [];
maxVal = [];

mixingMatrix = zeros(size(images{1},4),length(images),2);
thrs = zeros(size(images{1},4),length(images));
errorMask = false(size(images{1},1)*size(images{1},2),size(images{1},4),length(images));

if (showPlots)
    figure('Name',figureName,'NumberTitle','off');
    set(gcf,'Units','normalize','Position',[0 0 1 1]);
end

prgs = Utils.CmdlnProgress(length(images)^2,true,'Regressing');
for signalChan=1:length(images)
    curSignal = images{signalChan}; 
    imSignal = curSignal(:,:,:,signalChan);

    if (~isempty(zeroChannels) && ~any(zeroChannels==signalChan))
        imSignal = zeros(size(imSignal),'like',imSignal);
    end
    
    imSignal = [imSignal(:) ones(length(imSignal(:)),1)];
    for responceChan=1:size(images{signalChan},4)
        imResponce = curSignal(:,:,:,responceChan);
        if (responceChan==signalChan)
            mixingMatrix(responceChan,signalChan,:) = [1 0];
        else
            [mixingMatrix(responceChan,signalChan,:), ~] = regress(double(imResponce(:)),double(imSignal));
        end
        
        curVar = (imResponce(:)-(mixingMatrix(responceChan,signalChan,1)*imSignal(:,1))+mixingMatrix(responceChan,signalChan,2)).^2;
        thrs(responceChan,signalChan) = prctile(curVar,95);
        mask = reshape(curVar>thrs(responceChan,signalChan),size(imResponce));
        mask = max(mask,[],3);
        errorMask(:,responceChan,signalChan) = mask(:);
        
        if (showPlots)
            subplot(size(images{1},4),length(images),responceChan + (signalChan-1)*size(images{1},4));
            [minVal, maxVal] = Unmix.PlotRegression(imSignal,signalChan,responceChan,thrs(responceChan,signalChan),imSignal,imResponce,mixingMatrix,minVal,maxVal,mask);
        end
        
        prgs.PrintProgress((signalChan-1)*length(images) + responceChan);
    end
end

prgs.ClearProgress(true);

if (showPlots)
    drawnow
end

%% calculate unmixing
unmixingMatrix = inv(mixingMatrix(:,:,1));
end
