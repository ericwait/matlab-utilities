%% anisotropic downsampling of the montage data, i.e., the Z dimension is
% not downsampled, only in X and Y since X and Y are much larger than Z
function [imDataOut, reductionsOut] = GetReductions(imDataIn, maxTextureSize, level)

PaddingSize = 1;
numTilesXY = 2^level;

%Make New Metadata for Tiles
imDataOut = imDataIn;
% imDataOut.XDimension = floor(imDataIn.XDimension / numTilesXY);
% imDataOut.YDimension = floor(imDataIn.YDimension / numTilesXY);
imDataOut.ZDimension = imDataOut.ZDimension;

fit = false;
reductionsIn = [1 1 1];

while (~fit)
    
    imDataOut.XDimension = floor(floor(imDataIn.XDimension / numTilesXY)/reductionsIn(2));
    imDataOut.YDimension = floor(floor(imDataIn.YDimension / numTilesXY)/reductionsIn(1));
    %Too Large in X
    
%     if mod(reductionsIn(1),2)==0 && mod(imDataOut.ZDimension,reductionsIn(3))==0
%         reductionsIn(3) = reductionsIn(3)*2;
%     end
    numPanelsZ = imDataOut.ZDimension/reductionsIn(3);
    
    numPanelsX = min(floor(maxTextureSize/(imDataOut.XDimension + 2*PaddingSize)),numPanelsZ);
    if(numPanelsX < 1)
        [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn,1);
        continue;
    end
    %% Too Large in Y
    numPanelsY = ceil(numPanelsZ / numPanelsX);
    if(numPanelsY * (imDataOut.YDimension + 2*PaddingSize)) > maxTextureSize
        [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn,1);
        continue;
    end
    
    % DimX and DimY is dimension of the resized image
    
%     % if the reduced image can't be exactly divided by number of tiles
%     DimX = floor(imDataIn.XDimension/reductionsIn(2));
%     if(mod(DimX, numTilesXY) > 0)
%         [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn, 0.01);
%         continue;
%     end
%     
%     DimY = floor(imDataIn.YDimension/reductionsIn(1));
%     if(mod(DimY, numTilesXY) > 0)
%         [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn, 0.01);
%         continue;
%     else
%      end      
        fit = true;

end
reductionsOut = reductionsIn;

% imDataOut.XDimension = DimX/numTilesXY;
% imDataOut.YDimension = DimY/numTilesXY;
imDataOut.numImInX = numPanelsX;
imDataOut.numImInY = numPanelsY;
imDataOut.numImInZ = numPanelsZ;
imDataOut.outImWidth = maxTextureSize;

% reduce atlas Y dimension by power of 2
pwr2 = log2(maxTextureSize/(imDataOut.YDimension*imDataOut.numImInY));

imDataOut.outImHeight = maxTextureSize / 2^floor(pwr2);

imDataOut = MicroscopeData.Web.ConvertMetadata(imDataOut);
end
