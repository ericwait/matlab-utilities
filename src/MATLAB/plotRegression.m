function [minVal, maxVal] = plotRegression(imSinglePos,stain,chan,dif,imStain,imChan,factors,minVal,maxVal,inds)
if (~exist('maxVal','var') || isempty(maxVal))
    switch class(imSinglePos)
        case 'uint8'
            maxVal = 2^8-1;
            minVal = 0;
        case 'uint16'
            maxVal = 2^16-1;
            minVal = 0;
        case 'int16'
            maxVal = 2^16 /2 -1;
            minVal = 0;
        case 'uint32'
            maxVal = 2^32-1;
            minVal = 0;
        case 'int32'
            maxVal = 2^32 /2 -1;
            minVal = -maxVal -1;
        case 'single'
            maxVal = max(imSinglePos(:));
            minVal = min(imSinglePos(:));
            if (maxVal<1), maxVal=1; end
            if (minVal>0), minVal=0; end
        case 'double'
            maxVal = max(imSinglePos(:));
            minVal = min(imSinglePos(:));
            if (maxVal<1), maxVal=1; end
            if (minVal>0), minVal=0; end
    end
end
%fprintf('\tS:%d C:%d dif=%f\n',stain,chan,dif);
hold on
imSt = imStain(:,1);
imCh = imChan(:);
plot(imSt,imCh,'.b');
if (~isempty(inds))
    plot(imSt(inds),imCh(inds),'.r');
end

plot([minVal maxVal],factors(chan,stain,1)*[minVal maxVal]+factors(chan,stain,2),'--g');
ylim([minVal maxVal]);
xlim([minVal maxVal]);
xlabel(sprintf('(Signal Channel - %d',stain));
ylabel(sprintf('Responce Channel - %d',chan));
title(num2str(dif));
drawnow
end
