function [imColor,minValue,maxValue,minColor,maxColor] = ColorMapZeroCentWithLabel(im,axisHandle)
    if (~exist('axisHandle','var') || isempty(axisHandle))
        figure
        axisHandle = gca;
    end

    eMap = zeros(512,3);
    for i=1:size(eMap,1)
        gVal = 256-i;
        gVal = max(0,gVal);

        mVal = i-256-1;
        mVal = max(0,mVal);

        eMap(i,:) = [mVal,gVal,mVal];
    end
    eMap = eMap./255;
    
    divVert = ones(size(im,1),5,3,'uint8')*255;

    [imNeg,minValue,~,minColor] = ImUtils.ColorMapZeroCentered(min(im,[],3),eMap(1:256,:),eMap(257:end,:));
    [imPos,~,maxValue,maxColor] = ImUtils.ColorMapZeroCentered(max(im,[],3),eMap(1:256,:),eMap(257:end,:));
    imColor = imNeg+imPos;
    imshow(imColor,'parent',axisHandle)
    
    stepSize = (maxValue-minValue)/255;
    tickVals = minValue:stepSize:maxValue;
    [~,I] = min(abs(tickVals));
    negColors = imresize(eMap(1:256,:),[I,3]);
    posColors = imresize(eMap(257:end,:),[256-I,3]);
    allColors = vertcat(negColors,posColors);
    
    colormap(axisHandle,allColors);
    clbr = colorbar(axisHandle);
    clbr.Ticks = [0,I/256,1];
    clbr.TickLabels = {num2str(minValue,4),'0',num2str(maxValue,4)};
    
    
    clor = im2uint8(allColors);
    clor = imresize(permute(clor,[1,3,2]),[size(imColor,1),50]);
    clor = clor(end:-1:1,:,:);
    labl = im2uint8(ones([size(clor,1),size(clor,2)*2,size(clor,3)]));
    labl = insertText(labl,[size(clor,2),10],sprintf('%0.4g',maxValue),'TextColor','black','BoxOpacity',0,'AnchorPoint','Center','Font','Arial');
    labl = insertText(labl,[size(clor,2),size(labl,1)-10],sprintf('%0.4g',minValue),'TextColor','black','BoxOpacity',0,'AnchorPoint','Center','Font','Arial');
    imColor = cat(2,imColor,divVert,clor,divVert,labl);
end
