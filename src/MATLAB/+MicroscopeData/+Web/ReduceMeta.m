function [TileDataOut] = ReduceMeta(imDataIn,reductions,x,y,level,maxTextureSize)

PaddingSize = 1;
%% Downsample Metadata
TileDataOut = imDataIn;

TileDataOut.Level = level;
numTilesXY = 2^level;
TileSizeX = floor((imDataIn.XDimension / numTilesXY)/reductions(2));
TileSizeY = floor((imDataIn.YDimension / numTilesXY)/reductions(1));
numPanelsZ = floor(imDataIn.ZDimension / reductions(3));

numPanelsX = floor(maxTextureSize/(TileSizeX + 2*PaddingSize));
numPanelsX = min(numPanelsX,numPanelsZ);
numPanelsY = ceil(numPanelsZ / numPanelsX);

TileDataOut.Reduction = reductions;

%% Update the Tile Dimensions
TileDataOut.XDimension = TileSizeX;
TileDataOut.YDimension = TileSizeY;
TileDataOut.ZDimension = numPanelsZ;

%% Update Number of Tiles in Atlas
TileDataOut.numImInX = numPanelsX;
TileDataOut.numImInY = numPanelsY;
TileDataOut.numImInZ = numPanelsZ;

%% Update the Atlas Dimensions
TileDataOut.outImWidth = maxTextureSize;
% reduce atlas Y dimension to smallest power of two
pwr2 = log2(maxTextureSize/(TileDataOut.YDimension*TileDataOut.numImInY+PaddingSize));
TileDataOut.outImHeight = maxTextureSize / 2^floor(pwr2);
TileDataOut = MicroscopeData.Web.ConvertMetadata(TileDataOut);

%% Update Channels 
TileDataOut.NumberOfChannels = imDataIn.NumberOfChannels;
TileDataOut.ChannelNames = imDataIn.ChannelNames;
TileDataOut.ChannelColors = imDataIn.ChannelColors;
%% Update Resolution
TileDataOut.XPixelPhysicalSize = TileDataOut.PixelPhysicalSize(2) * reductions(2);
TileDataOut.YPixelPhysicalSize = TileDataOut.PixelPhysicalSize(1) * reductions(1);
TileDataOut.ZPixelPhysicalSize = TileDataOut.PixelPhysicalSize(3) * reductions(3);

%% Pixel Location
TileDataOut.XLocation = x;
TileDataOut.YLocation = y;
TileDataOut.PaddingSize = 1;

TileDataOut = MicroscopeData.Web.ConvertMetadata(TileDataOut);
end
