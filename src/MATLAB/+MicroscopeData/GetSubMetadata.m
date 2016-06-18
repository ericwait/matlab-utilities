function imageData =  GetSubMetadata(imageData,chanList,numFrames)
imageData.NumberOfFrames = numFrames;
imageData.NumberOfChannels = length(chanList);

imageData.ChannelColors = imageData.ChannelColors(chanList,:);
imageData.ChannelNames = imageData.ChannelNames(chanList);    
end