function [im, imD] = ReaderParT(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
%READERPARZ Summary of this function goes here
%   Detailed explanation goes here

if (~exist('pathOrImageData','var'))
    pathOrImageData = [];
end
if (~exist('outType','var') || isempty(outType))
    outType = [];
end
if (~exist('normalize','var') || isempty(normalize))
    normalize = false;
else
    normalize = logical(normalize);
end
if (~exist('quiet','var') || isempty(quiet))
    quiet = false;
else
    quiet = logical(quiet);
end
if (~exist('ROIstart_xy','var'))
    ROIstart_xy = [];
end

if (~exist('ROIsize_xy','var'))
    ROIsize_xy = [];
end

if (nargin==0)
    prompt = true;
elseif (~exist('prompt','var'))
    prompt = [];
end

imD = MicroscopeData.ReadMetadata(pathOrImageData,prompt);

if (isempty(imD))
    im = [];
    if (~quiet)
        warning('No Images read!');
    end
    return
end

clss = MicroscopeData.GetImageClass(imD);

if (~exist('chanList','var') || isempty(chanList))
    chanList = 1:imD.NumberOfChannels;
end

if (~exist('zList','var') || isempty(zList))
    zList = 1:imD.Dimensions(3);
end

if (~exist('timeList','var') || isempty(timeList))
    timeList = 1:imD.NumberOfFrames;
end

im1 = MicroscopeData.Reader(imD,timeList(1),chanList,zList,outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);

im = zeros(size(im1,1),size(im1,2),size(im1,3),size(im1,4),length(timeList),clss);
im(:,:,:,:,1) = im1;

clear im1

parfor t=2:length(timeList)
    im(:,:,:,:,t) = MicroscopeData.Reader(imD,timeList(t),chanList,zList,outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);
end

imD.Dimensions = [size(im,2),size(im,1),size(im,3)];
imD.NumberOfChannels = size(im,4);
imD.NumberOfFrames = size(im,5);
end

