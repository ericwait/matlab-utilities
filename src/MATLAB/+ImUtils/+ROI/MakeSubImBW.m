function [im,startCoords_rcz] = MakeSubImBW(size_rcz,indexList,padding)
%[im,shiftCoords_rcz] = ImUtils.ROI.MakeSubImBW(imSz_rcz,pixelIdxList,PADDING)

if (~exist('padding','var') || isempty(padding))
    padding = 0;
end

% get the extents in a bounding box
coords_rcz = Utils.IndToCoord(size_rcz,indexList);
bb_rcz = [min(coords_rcz,[],1);max(coords_rcz,[],1)];

% find the size for the sub image
startCoords_rcz = max(ones(1,size(bb_rcz,2)), bb_rcz(1,:) - padding);
endCoords_rcz = min(size_rcz, bb_rcz(2,:) + padding);
imSize_rcz = endCoords_rcz - startCoords_rcz +1;

% shift all coords by the start position 
shiftPixelCoords_rcz = coords_rcz - repmat(startCoords_rcz,size(coords_rcz,1),1) +1;
shiftPixelInd = Utils.CoordToInd(imSize_rcz,shiftPixelCoords_rcz);

% make the sub image
im = false(imSize_rcz);
im(shiftPixelInd) = true;
end
