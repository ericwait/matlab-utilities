function [im, imD] = ReaderParZ(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
%READERPARZ Summary of this function goes here
%   Detailed explanation goes here

imD = MicroscopeData.ReadMetadata(pathOrImageData,prompt);
clss = MicroscopeData.GetImageClass(imD);

if (~exist('zList','var') || isempty(zList))
    zList = 1:imD.Dimensions(3);
end

im1 = MicroscopeData.Reader(imD,timeList,chanList,zList(1),outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);

im = zeros(size(im1,1),size(im1,2),length(zList),length(chanList),size(im1,5),clss);
im(:,:,1,:) = im1;

clear im1

parfor z=2:length(zList)
    im(:,:,z,:,:) = MicroscopeData.Reader(imD,timeList,chanList,zList(z),outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);
end

imD.Dimensions = [size(im,2),size(im,1),size(im,3)];
end

