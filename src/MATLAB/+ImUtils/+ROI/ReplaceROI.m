function imOut = ReplaceROI(orgImage,roiImage,xStart,yStart,zStart)
if ~exist('zStart','var')
    zStart = 1;
end

imOut = orgImage;
imOut(yStart:yStart+size(roiImage,1)-1,xStart:xStart+size(roiImage,2)-1,zStart:zStart+size(roiImage,3)-1)...
    = roiImage;

end