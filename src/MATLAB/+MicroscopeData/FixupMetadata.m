function imageData = FixupMetadata(im,imageData)
imageData.Dimensions = Utils.SwapXY_RC(size(im(:,:,:,1,1)));
imageData.NumberOfChannels = size(im,4);
imageData.NumberOfFrames = size(im,5);

if (size(imageData.ChannelNames,1)>imageData.NumberOfChannels)
    imageData.ChannelNames = imageData.ChannelNames(1:imageData.NumberOfChannels);
end

if (size(imageData.ChannelColors,1)>imageData.NumberOfChannels)
    imageData.ChannelColors = imageData.ChannelColors(1:imageData.NumberOfChannels,:);
end

imageData.PixelFormat = class(im);
end