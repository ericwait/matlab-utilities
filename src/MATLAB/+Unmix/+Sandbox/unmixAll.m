function unmixAll()
global imageData

im = tiffReader('uint8');
imBW = zeros(size(im));
for chan=1:imageData.NumberOfChannels
    imBW(:,:,:,1,chan) = CudaMex('OtsuThresholdFilter',im(:,:,:,1,chan));
end

for chan1=1:imageData.NumberOfChannels
    for chan2=1:imageData.NumberOfChannels
        if (chan1==chan2),continue,end
        factor(chan1,chan2,:) = regress(double(im(:,:,:,1,chan1)));
    end
end
end
