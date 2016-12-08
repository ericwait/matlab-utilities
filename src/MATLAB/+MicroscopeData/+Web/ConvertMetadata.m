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
            ChannelColorsOut = [ChannelColorsOut; Cloneview3D.Helper.HexToDecimal(ChannelColorsIn{i})];
        end
    else
        if(size(ChannelColorsIn,2) > 1)
            return
        end
        ChannelColorsOut = Cloneview3D.Helper.HexToDecimal(ChannelColorsIn);
    end
end