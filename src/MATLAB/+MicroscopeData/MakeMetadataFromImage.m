function meta = MakeMetadataFromImage(im)
    colors = [0,1,0;...
              1,0,1;...
              0,1,1;...
              0,0,1;...
              1,0,0;...
              1,1,0];

    meta = MicroscopeData.GetEmptyMetadata();

    meta.DatasetName = 'im';
    meta.Dimensions = [size(im,2),size(im,1),size(im,3)];
    meta.NumberOfChannels = size(im,4);
    meta.NumberOfFrames = size(im,5);
    meta.PixelPhysicalSize = [1,1,1];
    
    if meta.NumberOfChannels == 1
        meta.ChannelNames = {'Channel 1'};
        meta.ChannelColors = [1, 1, 1];
    else
        for c=1:meta.NumberOfChannels
            meta.ChannelNames = [meta.ChannelNames; {sprintf('Channel %d',c)}];
            colidx = mod(c,size(colors,1))+1;
            meta.ChannelColors = vertcat(meta.ChannelColors,colors(colidx,:));
        end
    end

    meta.StartCaptureDate = datestr(now,'yyyy-mm-dd HH:MM:SS');
    meta.PixelFormat = class(im);
end