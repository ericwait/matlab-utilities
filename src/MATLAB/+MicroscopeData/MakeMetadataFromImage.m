function imageData = MakeMetadataFromImage(im)
colors = [1,0,0;...
          0,1,0;...
          0,0,1;...
          0,1,1;...
          1,0,1;...
          1,1,0];
      
imageData = MicroscopeData.GetEmptyMetadata();

imageData.DatasetName = 'im';
imageData.Dimensions = Utils.SwapXY_RC(size(im(:,:,:,1)));
imageData.NumberOfChannels = size(im,4);
imageData.NumberOfFrames = size(im,5);
imageData.PixelPhysicalSize = [1,1,1];
for c=1:imageData.NumberOfChannels
    imageData.ChannelNames = [imageData.ChannelNames; {sprintf('Channel %d',c)}];
    colidx = mod(c,size(colors,1));
    imageData.ChannelColors = vertcat(imageData.ChannelColors,colors(colidx,:));
end

imageData.StartCaptureDate = datestr(now,'yyyy-mm-dd HH:MM:SS');
imageData.PixelFormat = class(im);

end