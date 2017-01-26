%% Put z slices into the atlas texture
function makeAtlas(im, imData,tileDir,c,t)
imOut = zeros(imData.outImHeight,imData.outImWidth,1,'uint8');

%% pad the atlas to get rid of shader interpolation artifact, for png, 2 is enough
PaddingSize = imData.PaddingSize;
XDimension = imData.XDimension+2*PaddingSize;
YDimension = imData.YDimension+2*PaddingSize;

numImInX = imData.numImInX;
numImInY = imData.numImInY;
%% Pack the tiles into atlas, Reshape Z into XY

z = 1;
for y = 0:numImInY-1
    yStart = y * YDimension +1;
    yEnd = yStart + YDimension -1;
    for x = 0:numImInX-1
        xStart = x*XDimension+1;
        xEnd = xStart +XDimension -1;
        imOut(yStart:yEnd,xStart:xEnd,:) = padarray(im(:,:,z,:,:), [PaddingSize PaddingSize],'replicate','both');
        z = z + 1;
        if (z>imData.numImInZ), break; end
    end
    if (z>imData.numImInZ), break; end
end

if round(log2(size(imOut,1))) ~= log2(size(imOut,1)) || round(log2(size(imOut,2))) ~= log2(size(imOut,2))
    warning('Output atlas dims must be Power of 2');
end

%% Export The Tile
imwrite(imOut, fullfile(tileDir,sprintf('%s_c%02d_t%04d.png',imData.DatasetName,c,t)));
end



