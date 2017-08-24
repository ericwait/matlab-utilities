%% This code converts old metadata format into the new format or vise versa

function imData = ConvertMetadata(imData, isOld)

if (~exist('isOld','var') || isempty(isOld))
    isOld = isfield(imData, 'XDimension');
end
    if(isOld)
        imData.Dimensions(1) = imData.XDimension;
        imData.Dimensions(2) = imData.YDimension;
        imData.Dimensions(3) = imData.ZDimension;
        
        imData.PixelPhysicalSize(1) = imData.XPixelPhysicalSize;
        imData.PixelPhysicalSize(2) = imData.YPixelPhysicalSize;
        imData.PixelPhysicalSize(3) = imData.ZPixelPhysicalSize;
            
        imData.ChannelColors = ConvertColor(imData.ChannelColors);
    else
        imData.XDimension = imData.Dimensions(1);
        imData.YDimension = imData.Dimensions(2);
        imData.ZDimension = imData.Dimensions(3);
        
        imData.XPixelPhysicalSize = imData.PixelPhysicalSize(1);
        imData.YPixelPhysicalSize = imData.PixelPhysicalSize(2);
        imData.ZPixelPhysicalSize = imData.PixelPhysicalSize(3);        
    end
end

function ChannelColorsOut = ConvertColor(ChannelColorsIn)
    ChannelColorsOut = [];
    if(iscell(ChannelColorsIn))                
        for i = 1:numel(ChannelColorsIn)
            ChannelColorsOut = [ChannelColorsOut; HexToDecimal(ChannelColorsIn{i})];
        end
    else
%         if(size(ChannelColorsIn,2) > 1)
%             return
%         end
        ChannelColorsOut = ChannelColorsIn;
    end
end

%% A function that convert hex color to decimal float
function colorOut = HexToDecimal(color)
    
    if(iscell(color))
        color = cell2mat(color);
    end
    
    r = hex2dec(color(2:3))/255;
    g = hex2dec(color(4:5))/255;
    b = hex2dec(color(6:7))/255;
    
    colorOut = [r g b];    
end