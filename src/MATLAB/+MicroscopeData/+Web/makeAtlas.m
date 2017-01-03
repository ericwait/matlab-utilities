%% Put z slices into the atlas texture
function [imOut] = makeAtlas(im, imData, maxTextureSize)
imOut = zeros(imData.outImHeight,imData.outImWidth,1,'uint8');

% pad the atlas to get rid of shader interpolation artifact, for png, 2 is enough
PaddingSize = imData.PaddingSize;
XDimension = imData.XDimension+2*PaddingSize;
YDimension = imData.YDimension+2*PaddingSize;

% pack the tiles into atlas, Reshape Z into XY
z = 1;
for y = 0:imData.numImInY-1
    yStart = y * YDimension +1;
    yEnd = yStart + YDimension -1;
    for x = 0:imData.numImInX-1
        xStart = x*XDimension+1;
         xEnd = xStart +XDimension -1;
        imOut(yStart:yEnd,xStart:xEnd,:) = padarray(im(:,:,z,:,:), [PaddingSize PaddingSize],'replicate','both');
        z = z +1;
        if (z>imData.numImInZ), break; end
    end
    if (z>imData.numImInZ), break; end
end

if ~size(imOut,1) == maxTextureSize || ~size(imOut,2) == maxTextureSize
warning(['Output atlas dims must be ' num2str(maxTextureSize)]);
end 

end



