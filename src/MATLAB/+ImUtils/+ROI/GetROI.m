function imOut = GetROI(imIn, xStart, yStart, zStart, width, height, depth)
if ~exist('zStart','var')
    zStart = 1;
    depth = 2;
end

imOut = imIn(yStart:yStart+height-1,xStart:xStart+width-1,zStart:zStart+depth-1);

end