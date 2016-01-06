function [im, imD] = ReaderParT(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
%READERPARZ Summary of this function goes here
%   Detailed explanation goes here

imD = MicroscopeData.ReadMetadata(pathOrImageData,prompt);
clss = MicroscopeData.GetImageClass(imD);

if (~exist('timeList','var') || isempty(timeList))
    timeList = 1:imD.NumberOfFrames;
end

im1 = MicroscopeData.Reader(imD,timeList(1),chanList,zList,outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);

im = zeros(size(im1,1),size(im1,2),size(im1,3),size(im1,4),length(timeList),clss);
im(:,:,1,:) = im1;

clear im1

parfor t=2:length(timeList)
    im(:,:,:,:,t) = MicroscopeData.Reader(imD,timeList(t),chanList,zList,outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);
end

imD.Dimensions = [size(im,2),size(im,1),size(im,3)];
imD.NumberOfFrames = length(timeList);
end

