function imDataOut = ConvertData(imageData)
imDataOut = struct('DatasetName',{''},'Dimensions',{[]},'NumberOfChannels',{},'NumberOfFrames',{},...
    'PixelPhysicalSize',{[]},'Position',{[]},'ChannelNames',{''},'ChannelColors',{''},'StartCaptureDate',{''},...
    'TimeStampDelta',{[]});

imDataOut(1).DatasetName = imageData.DatasetName;

if (isfield(imageData,'XDimension'))
    imDataOut.Dimensions = [imageData.XDimension,...
                            imageData.YDimension,...
                            imageData.ZDimension];
elseif (isfield(imageData,'Dimensions'))
    if (size(imageData.Dimensions,1)~=1)
        if (size(imageData.Dimensions,2)~=1)
            error('Malformed Dimensions!');
        end
        imDataOut.Dimensions = imageData.Dimensions';
    else
        imDataOut.Dimensions = imageData.Dimensions;
    end
end

imDataOut.NumberOfChannels = imageData.NumberOfChannels;
imDataOut.NumberOfFrames = imageData.NumberOfFrames;

if (isfield(imageData,'XPixelPhysicalSize'))
    imDataOut.PixelPhysicalSize = [imageData.XPixelPhysicalSize,...
                                   imageData.YPixelPhysicalSize,...
                                   imageData.ZPixelPhysicalSize];
elseif (isfield(imageData,'PixelPhysicalSize'))
    if (size(imageData.PixelPhysicalSize,1)~=1)
        if (size(imageData.PixelPhysicalSize,2)~=1)
            error('Malformed PixelPhysicalSize!');
        end
        imDataOut.PixelPhysicalSize = imageData.PixelPhysicalSize';
    else
        imDataOut.PixelPhysicalSize = imageData.PixelPhysicalSize;
    end
end

if (isfield(imageData,'XPosition'))
    imDataOut.Position = [imageData.XPosition,...
                          imageData.YPosition,...
                          imageData.ZPosition];
elseif (isfield(imageData,'Position'))
    if (~isempty(imageData.Position))
        if (size(imageData.Position,1)~=1)
            if (size(imageData.Position,2)~=1)
                error('Malformed Position!');
            end
            imDataOut.Position = imageData.Position';
        else
            imDataOut.Position = imageData.Position;
        end
    end
end

if (isfield(imageData,'ChannelColors'))
    if (ischar(imageData.ChannelColors))
        colorKeep = cellfun(@(x) ~isempty(x),imageData.ChannelColors);
        keep = colorKeep >0;
        imageData.ChannelColors = imageData.ChannelColors(keep);
        if (size(imageData.ChannelColors,1)==1)
            imDataOut.ChannelNames = imageData.ChannelColors';
        else
            imDataOut.ChannelNames = imageData.ChannelColors;
        end
    elseif (iscell(imageData.ChannelColors))
        colorKeep = cellfun(@(x) ~isempty(x),imageData.ChannelColors);
        keep = colorKeep >0;
        imageData.ChannelColors = imageData.ChannelColors(keep);
        if (~isempty(imageData.ChannelColors))
            imDataOut.ChannelNames = imageData.ChannelColors;
        end
    else
        imDataOut.ChannelColors = imageData.ChannelColors;
    end
end

if (isfield(imageData,'ChannelNames'))
    imDataOut.ChannelNames = imageData.ChannelNames;
end

if (isempty(imDataOut.ChannelNames) && isempty(imDataOut.ChannelColors))
    [colors,stains] = MicroscopeData.Colors.GetChannelColors(imageData);
    imDataOut.ChannelColors = colors;
    imDataOut.ChannelNames = stains';
end

if (isfield(imageData,'StartCaptureDate'))
    imDataOut.StartCaptureDate = imageData.StartCaptureDate;
end

if (isfield(imageData,'TimeStampDelta'))
    imDataOut.TimeStampDelta = imageData.TimeStampDelta;
end

end
