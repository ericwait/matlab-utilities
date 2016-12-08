%% anisotropic downsampling of the montage data, i.e., the Z dimension is
% not downsampled, only in X and Y since X and Y are much larger than Z
function [imDataOut, reductionsOut] = GetReductions(imDataIn, maxTextureSize, level)
    
    PaddingSize = 1;
    numTilesXY = 2^level;
    tileData = imDataIn;
    tileData.XDimension = floor(imDataIn.XDimension / numTilesXY);
    tileData.YDimension = floor(imDataIn.YDimension / numTilesXY);

    imDataOut = imDataIn;
    
    imDataOut.XDimension = tileData.XDimension;
    imDataOut.YDimension = tileData.YDimension;
    imDataOut.ZDimension = tileData.ZDimension;
    
    fit = false;
    reductionsIn = [1 1 1];

while (~fit)
        numImInX = min(floor(maxTextureSize/(imDataOut.XDimension + 2*PaddingSize)),imDataOut.ZDimension);
        if(numImInX < 1)
            [imDataOut,reductionsIn] = reduc(reductionsIn,tileData);
            continue;
        end
        
        numImInY = ceil(imDataOut.ZDimension / numImInX);
        if(numImInY * (imDataOut.YDimension + 2*PaddingSize) > maxTextureSize)
            [imDataOut,reductionsIn] = Web.reduce(reductionsIn,tileData);
            continue;
        end
        
        % DimX and DimY is dimension of the resized orginal image
        DimX = floor(imDataIn.XDimension/reductionsIn(2));        

        % if the reduced image can't be exactly divided by number of tiles
        if(mod(DimX, numTilesXY) > 0)
            [imDataOut,reductionsIn] = Web.reduce(reductionsIn,tileData, 0.0001);
            continue;
        end
        
        DimY = floor(imDataIn.YDimension/reductionsIn(1));
        if(mod(DimY, numTilesXY) > 0)
            [imDataOut,reductionsIn] = Web.reduce(reductionsIn,tileData, 0.0001);
            continue;
        else
            fit = true;
            
        end    
end
    reductionsOut = reductionsIn; 
    
    imDataOut.XDimension = DimX/numTilesXY;
    imDataOut.YDimension = DimY/numTilesXY;
    imDataOut.numImInX = numImInX;
    imDataOut.numImInY = numImInY;
    imDataOut.outImWidth = maxTextureSize;
    
    % reduce atlas Y dimension by power of 2
    pwr2 = log2(maxTextureSize/(imDataOut.YDimension*imDataOut.numImInY));
    if(pwr2 > 1)
        imDataOut.outImHeight = maxTextureSize / 2^floor(pwr2);
    else
        imDataOut.outImHeight = maxTextureSize;
    end
    imDataOut = Web.ConvertMetadata(imDataOut);
end
