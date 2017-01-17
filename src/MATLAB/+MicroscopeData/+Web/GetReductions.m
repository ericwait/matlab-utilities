%% anisotropic downsampling of the montage data, i.e., the Z dimension is
% not downsampled, only in X and Y since X and Y are much larger than Z
function [reductionsOut] = GetReductions(imDataIn, maxTextureSize, level)

PaddingSize = 1;
numTilesXY = 2^level;

%Make New Metadata for Tiles
fit = false;
reductionsIn = [1 1 1];

while (~fit)
    
    TileSizeX = floor((imDataIn.Dimensions(1) / numTilesXY)/reductionsIn(1));
    TileSizeY = floor((imDataIn.Dimensions(2) / numTilesXY)/reductionsIn(2));
    numPanelsZ = floor(imDataIn.Dimensions(3) /reductionsIn(3));
      
    numPanelsX = max(floor(maxTextureSize/(TileSizeX + 2*PaddingSize)),1);
    numPanelsX = min(numPanelsX,numPanelsZ);
    numPanelsY = ceil(numPanelsZ / numPanelsX);
    
    %Too Large in X 
    if ((TileSizeX + 2*PaddingSize) * numPanelsX) > maxTextureSize
        [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn,2,[TileSizeX,TileSizeY,numPanelsZ]);
        continue;
    end
    %% Too Large in Y
    if ((TileSizeY + 2*PaddingSize) * numPanelsY) > maxTextureSize
        [reductionsIn] = MicroscopeData.Web.reduce(reductionsIn,2,[TileSizeX,TileSizeY,numPanelsZ]);
        continue;
    end
        
    fit = true;
end

reductionsOut = reductionsIn;
end
