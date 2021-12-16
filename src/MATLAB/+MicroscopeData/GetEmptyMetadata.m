function imageData = GetEmptyMetadata(im)
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
imageData.ChannelNames = '';
imageData.StartCaptureDate = '';
imageData.ChannelColors = [];
imageData.PixelFormat = 'none';
imageData.TimeStampDelta = 0;
imageData.imageDir = '.';

if exist("im","var") && ~isempty(im)
    imageData.Dimensions = size(im,1:3);
    imageData.NumberOfChannels = size(im,4);
    imageData.NumberOfFrames = size(im,5);
    imageData.PixelPhysicalSize = [1,1,1];
else
    imageData.Dimensions = [0,0,0];
    imageData.NumberOfChannels = 0;
    imageData.NumberOfFrames = 0;
    imageData.PixelPhysicalSize = [0,0,0];
end
end