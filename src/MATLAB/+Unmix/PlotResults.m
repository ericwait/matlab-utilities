function PlotResults(images,figureName,errorMask)
    figureHandle = figure('Name',figureName,'NumberTitle','off');
    prgs = Utils.CmdlnProgress(length(images)*size(images{1},4),true,'Plotting images');
    for signalChan=1:length(images)
        imSignal = images{signalChan};
        for responceChan=1:size(images{1},4)
            imResponce = imSignal(:,:,:,responceChan);
            
            set(0, 'CurrentFigure', figureHandle);
            axHandle = subplot(length(images),size(images{1},4),responceChan + (signalChan-1)*size(images{1},4));
            ImUtils.ThreeD.ShowMaxImage(imResponce,false,3,axHandle);
            if (~isempty(errorMask))
                hold on
                inds = find(errorMask(:,responceChan,signalChan));
                [r,c] = ind2sub([size(imSignal,1),size(imSignal,2)],inds);
                plot(axHandle,c,r,'.r','MarkerSize',1);
            end
            colorbar
            
            prgs.PrintProgress((signalChan-1)*length(images) + responceChan);
        end
    end
    set(gcf,'Units','normalized','Position',[0 0 1 1]);
    drawnow
    
    prgs.ClearProgress(true);
end