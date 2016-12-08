%% Put z slices into the atlas texture

function [imOut, imDataOut] = makeAtlas(im, imData, maxTextureSize)
imOut = zeros(imData.outImHeight,imData.outImWidth,1,imData.NumberOfFrames,'uint8');

% pad the atlas to get rid of shader interpolation artifact, for png, 2 is
% enough
PaddingSize = 1;
XDimension = imData.XDimension+2*PaddingSize;
YDimension = imData.YDimension+2*PaddingSize;


% pack the tiles into atlas
z = 1;
for y = 0:imData.numImInY-1
    yStart = y*YDimension +1;
    yEnd = yStart +YDimension -1;
    for x = 0:imData.numImInX-1
        xStart = x*XDimension +1;
        xEnd = xStart +XDimension -1;
        imOut(yStart:yEnd,xStart:xEnd,:) = padarray(im(:,:,z,:,:), [PaddingSize PaddingSize],'replicate','both');
        z = z +1;
        if (z>imData.ZDimension), break; end
    end
    if (z>imData.ZDimension), break; end
end

imDataOut = imData;
imDataOut.PaddingSize = PaddingSize;
end



