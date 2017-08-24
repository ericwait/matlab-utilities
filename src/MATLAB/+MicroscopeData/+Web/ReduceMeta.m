function [TileDataOut] = ReduceMeta(imDataIn,LevelIn,Location,ROI)

TileDataOut = imDataIn;
%% Calculate Reductions
Partitions = LevelIn.Partitions(1,:);
Reductions = LevelIn.Reductions(1,:);
TileDataOut.Partitions = Partitions;
TileDataOut.Reduction = Reductions;

%% Update the Tile Dimensions
ChunkSizeX = floor((imDataIn.Dimensions(1) / Partitions(1)) / Reductions(1));
ChunkSizeY = floor((imDataIn.Dimensions(2) / Partitions(2)) / Reductions(2));
ChunkSizeZ = floor((imDataIn.Dimensions(3) / Partitions(3) / Reductions(3)));
TileDataOut.Dimensions = [ChunkSizeX,ChunkSizeY,ChunkSizeZ];

%% Pixel Location
TileDataOut.Location = Location;
TileDataOut.ROI = ROI;
TileDataOut.TLF = ROI(1,:);
TileDataOut.BRR = ROI(2,:);

end
