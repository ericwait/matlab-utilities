%% anisotropic downsampling of the montage data, i.e., the Z dimension is
% not downsampled, only in X and Y since X and Y are much larger than Z
function [reductionsOut] = GetReductions(imDataIn, maxTextureSize, level)

PaddingSize = 1;
numTilesXY = 2^level;

%Make New Metadata for Tiles
imDataOut = imDataIn;

fit = false;
reductionsIn = [1 1 1];

while (~fit)
    
    TileSizeX = floor((imDataIn.XDimension / numTilesXY)/reductionsIn(2));
    TileSizeY = floor((imDataIn.YDimension / numTilesXY)/reductionsIn(1));
    numPanelsZ = floor(imDataIn.ZDimension/reductionsIn(3));
      
    numPanelsX = floor(maxTextureSize/(TileSizeX + 2*PaddingSize));
    numPanelsX = min(numPanelsX,numPanelsZ);
    
    %Too Large in X 
    if(TileSizeX*numTilesXY > maxTextureSize)
        [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn,1,[TileSizeX,TileSizeY,numPanelsZ]);
        continue;
    end
    %% Too Large in Y
    numPanelsY = ceil(numPanelsZ / numPanelsX);
    if(numPanelsY * (TileSizeY + 2*PaddingSize)) > maxTextureSize
        [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn,1,[TileSizeX,TileSizeY,numPanelsZ]);
        continue;
    end
        
    fit = true;
end

reductionsOut = reductionsIn;



imDataOut.XDimension = TileSizeX;
imDataOut.YDimension = TileSizeY;
imDataOut.ZDimension = numPanelsZ;

imDataOut.numImInX = numPanelsX;
imDataOut.numImInY = numPanelsY;
imDataOut.numImInZ = numPanelsZ;
imDataOut.outImWidth = maxTextureSize;
 
% reduce atlas Y dimension by power of 2
pwr2 = log2(maxTextureSize/(imDataOut.YDimension*imDataOut.numImInY+PaddingSize));
imDataOut.outImHeight = maxTextureSize / 2^floor(pwr2);
imDataOut = MicroscopeData.Web.ConvertMetadata(imDataOut);
end
