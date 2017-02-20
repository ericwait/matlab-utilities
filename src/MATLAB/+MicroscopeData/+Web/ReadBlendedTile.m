%% This function reads CloneView3D composed atlas textures and unpack it into 5D data
%   @root - is the path of the tile, for example, 3mon_SVZ/3mon_SVZ/4/0810
%   @AtlasColorChannels - is the color channels of the atlas, for example, a
%   32bit png texture should have 4 color channels RGBA, while jpg or tif
%   should have 3 color channels

function [imOut, imData] = ReadBlendedTile(root, channelList, AtlasColorChannels)
	
if (~exist('root','var') || isempty(root))
return   
   %root = uigetdir('B:\javascript\experiments\Itga9 WT2 Deep Labels 8-04-13_pad1\DAPI GFAP-514 laminin-488 EdU-647\4\1413','Choose Output Directory');
end

imData = MicroscopeData.ReadMetadata(root,0);
if (~exist('AtlasColorChannels','var') || isempty(AtlasColorChannels))
    AtlasColorChannels = min(3,imData.NumberOfChannels);
end


if (~exist('channelList','var') || isempty(channelList))
    channelList = 1:imData.NumberOfChannels;
end

numMix = ceil(imData.NumberOfChannels / AtlasColorChannels);
PaddingSize = imData.PaddingSize;

imName = [imData.DatasetName, sprintf('_blend_c%02d_t%04d.png', 1, 1)];
tempIm = imread(fullfile(imData.imageDir, imName));
   
[YDim, XDim, ~] = size(tempIm);
imAtlas = zeros(YDim, XDim, imData.NumberOfChannels, 'uint8');
im = zeros(imData.YDimension+2*PaddingSize, imData.XDimension+2*PaddingSize, imData.ZDimension,imData.NumberOfChannels, 'uint8');
t = 1;

for m = 1:numMix
    imName = [imData.DatasetName, sprintf('_blend_c%02d_t%04d.png', m, t)];
    if(AtlasColorChannels == 4)
        [imBlend,~, alpha] = imread(fullfile(root, imName)); 
        imBlend(:,:,4) = alpha;
    else
        imBlend= imread(fullfile(root, imName)); 
    end
    imAtlas(:,:,1 + (m-1)*AtlasColorChannels:m*AtlasColorChannels) = imBlend(:,:,1:AtlasColorChannels);
end
	

%% unpack the atlas
z = 1;
PaddingSize = imData.PaddingSize;
numImInX = imData.NumberOfImagesWide;
numImInY = imData.NumberOfImagesHigh;
XDimension = imData.XDimension+2*PaddingSize;
YDimension = imData.YDimension+2*PaddingSize;

for y = 0:numImInY-1
    yStart = y * YDimension +1;
    yEnd = yStart + YDimension -1;
    for x = 0:numImInX-1
        xStart = x*XDimension+1;
        xEnd = xStart +XDimension -1;
        im(:,:,z,:) = imAtlas(yStart:yEnd,xStart:xEnd,:,:);        
        z = z +1;
        if (z>imData.ZDimension), break; end
    end
    if (z>imData.ZDimension), break; end
end


%% only keep the channels in channelList
    imOut = im(:,:,:,channelList);

end