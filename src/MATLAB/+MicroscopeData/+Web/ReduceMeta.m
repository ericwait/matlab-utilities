function [TileDataOut] = ReduceMeta(imData,TileDataIn, reductions,x,y)

%% Downsample Metadata 
TileDataOut = TileDataIn;
% TileDataOut.XDimension = ceil(imData.XDimension/reductions(2));
% TileDataOut.YDimension = ceil(imData.YDimension/reductions(1));
% TileDataOut.ZDimension = ceil(imData.ZDimension/reductions(3));

TileDataOut.XPixelPhysicalSize = TileDataIn.PixelPhysicalSize(2) * reductions(2);
TileDataOut.YPixelPhysicalSize = TileDataIn.PixelPhysicalSize(1) * reductions(1);
TileDataOut.ZPixelPhysicalSize = TileDataIn.PixelPhysicalSize(3) * reductions(3);

TileDataOut.XLocation = x;
TileDataOut.YLocation = y;
TileDataOut.PaddingSize = 1;

TileDataOut = MicroscopeData.Web.ConvertMetadata(TileDataOut);
 end
