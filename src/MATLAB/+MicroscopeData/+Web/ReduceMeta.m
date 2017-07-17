function [TileDataOut] = ReduceMeta(imDataIn,LevelIn,x,y,z)

%% Calculate Reductions
nPartitions = LevelIn.nPartitions(1,:);
Reductions = LevelIn.Reductions(1,:);

%% Downsample Metadata
TileDataOut = imDataIn;

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
