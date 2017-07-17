%% This function reads CloneView3D composed atlas textures and unpack it into 5D data
%   @root - is the path of the tile, for example, 3mon_SVZ/3mon_SVZ/4/0810
%   @AtlasColorChannels - is the color channels of the atlas, for example, a
%   32bit png texture should have 4 color channels RGBA, while jpg or tif
%   should have 3 color channels

function [imOut, TileData] = ReadBlendedTile(imData, root, channelList, AtlasColorChannels)
	
if (~exist('root','var') || isempty(root))
return   
   %root = uigetdir('B:\javascript\experiments\Itga9 WT2 Deep Labels 8-04-13_pad1\DAPI GFAP-514 laminin-488 EdU-647\4\1413','Choose Output Directory');
end

TileData = MicroscopeData.ReadMetadata(root,0);
if (~exist('AtlasColorChannels','var') || isempty(AtlasColorChannels))
    AtlasColorChannels = min(3,imData.NumberOfChannels);
end


if (~exist('channelList','var') || isempty(channelList))
    channelList = 1:imData.NumberOfChannels;
end

numMix = ceil(imData.NumberOfChannels / AtlasColorChannels);
PaddingSize = TileData.PaddingSize;

imName = [TileData.DatasetName, sprintf('_blend_c%02d_t%04d.png', 1, 1)];
tempIm = imread(fullfile(TileData.imageDir, imName));
   
[YDim, XDim, ~] = size(tempIm);
imAtlas = zeros(YDim, XDim, imData.NumberOfChannels, 'uint8');
im = zeros(TileData.Dimensions(2)+2*PaddingSize, TileData.Dimensions(1)+2*PaddingSize, TileData.Dimensions(3),imData.NumberOfChannels, 'uint8');
t = 1;

for m = 1:numMix
    imName = [TileData.DatasetName, sprintf('_blend_c%02d_t%04d.png', m, t)];
    if(AtlasColorChannels == 4)
        [imBlend,~, alpha] = imread(fullfile(root, imName)); 
        imBlend(:,:,4) = alpha;
    else
        imBlend= imread(fullfile(root, imName)); 
    end

    chanStart = AtlasColorChannels*(m-1)+ 1;
    chanEnd = AtlasColorChannels*(m);
    channels = chanStart:  min(chanEnd,imData.NumberOfChannels);
    if length(channels)==2; imBlend = imBlend(:,:,1:2); end 
    imAtlas(:,:,channels) = imBlend;
end
	

%% unpack the atlas
z = 1;
PaddingSize = TileData.PaddingSize;
numImInX = TileData.NumberOfImagesWide;
numImInY = TileData.NumberOfImagesHigh;
XDimension = TileData.Dimensions(1)+2*PaddingSize;
YDimension = TileData.Dimensions(2)+2*PaddingSize;

for y = 0:numImInY-1
    yStart = y * YDimension +1;
    yEnd = yStart + YDimension -1;
    for x = 0:numImInX-1
        xStart = x*XDimension+1;
        xEnd = xStart +XDimension -1;
        im(:,:,z,:) = imAtlas(yStart:yEnd,xStart:xEnd,:,:);        
        z = z +1;
        if (z>TileData.Dimensions(3)), break; end
    end
    if (z>TileData.Dimensions(3)), break; end
end


%% only keep the channels in channelList
    imOut = im(:,:,:,channelList);

end