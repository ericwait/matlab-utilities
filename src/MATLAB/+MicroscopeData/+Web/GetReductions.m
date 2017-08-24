%% anisotropic downsampling of the montage data, i.e., the Z dimension is
% not downsampled, only in X and Y since X and Y are much larger than Z
function [reductionsOut] = GetReductions(imDataIn, maxTextureSize,NumTiles)

PaddingSize = 1;

%Make New Metadata for Tiles
fit = false;
reductionsIn = [1 1 1];

while (~fit)
    
    TileSizeX  = floor((imDataIn.Dimensions(1) / NumTiles(1))/reductionsIn(1));
    TileSizeY  = floor((imDataIn.Dimensions(2) / NumTiles(2))/reductionsIn(2));
    numPanelsZ = floor((imDataIn.Dimensions(3) / NumTiles(3))/reductionsIn(3));
      
    numPanelsX = ceil(sqrt(numPanelsZ));
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
