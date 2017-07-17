function [TileDataOut] = ReduceMeta(imDataIn,x,y,z,L)

%% Calculate Reductions
AtlasSize = imDataIn.AtlasSize(L,:);
nPartitions = imDataIn.nPartitions(L,:);
Reductions = imDataIn.Reductions(L,:);

PaddingSize = 1;
%% Downsample Metadata
TileDataOut = imDataIn;

% TileDataOut.Level = Levelinfo.BULevel;
% TileDataOut.TDLevel = Levelinfo.TDLevel;

    TileSizeX = floor((imDataIn.Dimensions(1) / nPartitions(1)) / Reductions(1));
    TileSizeY = floor((imDataIn.Dimensions(2) / nPartitions(2)) / Reductions(2));
    
    numPanelsZ = floor((imDataIn.Dimensions(3) / nPartitions(3) / Reductions(3)));
    numPanelsX = ceil(sqrt(numPanelsZ));
    numPanelsX = min(numPanelsX,numPanelsZ);
    numPanelsY = ceil(numPanelsZ / numPanelsX);

TileDataOut.Reduction = Reductions;

%% Update the Tile Dimensions
TileDataOut.Dimensions = [TileSizeX,TileSizeY,numPanelsZ];
%% Update Number of Tiles in Atlas
TileDataOut.numImIn = [numPanelsX,numPanelsY,numPanelsZ];
%% Update the Atlas Dimensions
TileDataOut.outImWidth = AtlasSize(1);
% reduce atlas Y dimension to smallest power of two
pwr2 = log2(TileDataOut.numImIn(2)*(TileDataOut.Dimensions(2)+2*PaddingSize));
TileDataOut.outImHeight = 2^ceil(pwr2);

%% Update Channels 
TileDataOut.NumberOfChannels = imDataIn.NumberOfChannels;
TileDataOut.ChannelNames = imDataIn.ChannelNames;
TileDataOut.ChannelColors = imDataIn.ChannelColors;
%% Update Resolution
TileDataOut.PixelPhysicalSize(1) = TileDataOut.PixelPhysicalSize(1) * Reductions(1);
TileDataOut.PixelPhysicalSize(2) = TileDataOut.PixelPhysicalSize(2) * Reductions(2);
TileDataOut.PixelPhysicalSize(3) = TileDataOut.PixelPhysicalSize(3) * Reductions(3);

%% Pixel Location
TileDataOut.XLocation = x;
TileDataOut.YLocation = y;
TileDataOut.ZLocation = z;

TileDataOut.PaddingSize = 1;
end
