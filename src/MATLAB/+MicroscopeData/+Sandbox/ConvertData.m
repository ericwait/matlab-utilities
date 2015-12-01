function imDataOut = ConvertData(imageData)
imDataOut = struct('DatasetName',{''},'Dimensions',{[]},'NumberOfChannels',{},'NumberOfFrames',{},...
    'PixelPhysicalSize',{[]},'Position',{[]},'ChannelColors',{''},'StartCaptureData',{''},...
    'TimeStampDelta',{[]});

imDataOut(1).DatasetName = imageData.DatasetName;

imDataOut.Dimensions = [imageData.XDimension;...
                        imageData.YDimension;...
                        imageData.ZDimension];

imDataOut.NumberOfChannels = imageData.NumberOfChannels;
imDataOut.NumberOfFrames = imageData.NumberOfFrames;

imDataOut.PixelPhysicalSize = [imageData.XPixelPhysicalSize;...
                               imageData.YPixelPhysicalSize;...
                               imageData.ZPixelPhysicalSize];
if (isfield(imageData,'XPosition'))
    imDataOut.Position = [imageData.XPosition;...
                          imageData.YPosition;...
                          imageData.ZPosition];
end
    
if (isfield(imageData,'ChannelColors'))
    imDataOut.ChannelColors = imageData.ChannelColors';
end

imDataOut.StartCaptureData = imageData.StartCaptureDate;

if (isfield(imageData,'TimeStampDelta'))
    imDataOut.TimeStampDelta = imageData.TimeStampDelta;
end

end
