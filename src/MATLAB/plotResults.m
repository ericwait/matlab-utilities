function plotResults(images,figureName,errorMask)
    figure('Name',figureName,'NumberTitle','off');
    for signalChan=1:size(images,5)
        for responceChan=1:size(images,4)
            imResponce = images(:,:,:,responceChan,signalChan);
            
            subplot(size(images,4),size(images,5),responceChan + (signalChan-1)*size(images,4));
            showMaxImage(imResponce,false,3);
            if (~isempty(errorMask))
                hold on
                inds = find(errorMask(:,responceChan,signalChan));
                [r,c] = ind2sub([size(images,1),size(images,2)],inds);
                plot(c,r,'.r','MarkerSize',1);
            end
            colorbar
        end
    end
    set(gcf,'Units','normalized','Position',[0 0 1 1]);
    drawnow
end