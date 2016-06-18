function imageData = GetEmptyMetadata()
imageData = struct('DatasetName',{''},...
    'Dimensions',{[0,0,0]},...
    'NumberOfChannels',{0},...
    'NumberOfFrames',{0},...
    'PixelPhysicalSize',{[1,1,1]},...
    'ChannelNames',{''},...
    'StartCaptureDate',{},...
    'ChannelColors',{[]},...
    'PixelFormat',{''});

imageData(1).DatasetName = '';
imageData.Dimensions = [0,0,0];
imageData.NumberOfChannels = 0;
imageData.NumberOfFrames = 0;
imageData.PixelPhysicalSize = [0,0,0];
imageData.ChannelNames = '';
imageData.StartCaptureDate = '';
imageData.ChannelColors = [];
imageData.PixelFormat = 'none';
end