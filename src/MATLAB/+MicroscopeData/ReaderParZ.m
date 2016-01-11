function [im, imD] = ReaderParZ(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
%[im, imD] = ReaderParZ(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)

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
clss = MicroscopeData.GetImageClass(imD);

if (~exist('chanList','var') || isempty(chanList))
    chanList = 1:imD.NumberOfChannels;
end
if (~exist('timeList','var') || isempty(timeList))
    timeList = 1:imD.NumberOfFrames;
end

if (~exist('zList','var') || isempty(zList))
    zList = 1:imD.Dimensions(3);
end

im1 = MicroscopeData.Reader(imD,timeList,chanList,zList(1),outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);

im = zeros(size(im1,1),size(im1,2),length(zList),length(chanList),size(im1,5),clss);
im(:,:,1,:,:) = im1;

clear im1

parfor z=2:length(zList)
    im(:,:,z,:,:) = MicroscopeData.Reader(imD,timeList,chanList,zList(z),outType,normalize,quiet,prompt,ROIstart_xy,ROIsize_xy);
end

imD.Dimensions = [size(im,2),size(im,1),size(im,3)];
imD.NumberOfChannels = size(im,4);
imD.NumberOfFrames = size(im,5);
end

