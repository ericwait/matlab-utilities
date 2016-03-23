function [im, imD] = ReaderMIP(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
%[im, imD] = MicroscopeData.ReaderMIP(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)

if (~exist('pathOrImageData','var'))
    pathOrImageData = [];
end
if (~exist('prompt','var'))
    prompt = [];
end

imD = MicroscopeData.ReadMetadata(pathOrImageData,prompt);
clss = MicroscopeData.GetImageClass(imD);

if (~exist('timeList','var') || isempty(timeList))
    timeList = 1:imD.NumberOfFrames;
end
if (~exist('chanList','var') || isempty(chanList))
    chanList = 1:imD.NumberOfChannels;
end
if (~exist('zList','var') || isempty(zList))
    zList = 1:imD.Dimensions(3);
end
if (~exist('outType','var') || isempty(outType))
    outType = clss;
end
if (~exist('normalize','var'))
    normalize = [];
end
if (~exist('quiet','var'))
    quiet = false;
end
if (~exist('ROIstart_xy','var') || isempty(ROIstart_xy))
    ROIstart_xy = [1,1];
end
if (~exist('ROIsize_xy','var') || isempty(ROIsize_xy))
    ROIsize_xy(1) = length(ROIstart_xy(1):imD.Dimensions(1));
    ROIsize_xy(2) = length(ROIstart_xy(2):imD.Dimensions(2));
end

mipPathTemplate = ['_',imD.DatasetName,'_c%02d_t%04d.tif'];
gotMips = false(length(timeList),length(chanList));
for t=1:length(timeList)
    for c=1:length(chanList)
        curFile = fullfile(imD.imageDir, sprintf(mipPathTemplate,chanList(c),timeList(t)));
        if (exist(curFile,'file'))
            im(:,:,1,c,t) = imread(curFile);
            gotMips(t,c) = true;
        end
    end
end


if (~quiet)
    iter = sum(gotMips==0)*imD.Dimensions(3);
    cp = Utils.CmdlnProgress(iter,true);
    i=1;
end

if (strcmpi(outType,'logical'))
    im = false(ROIsize_xy(2),ROIsize_xy(1),1,length(chanList),length(timeList));
else
    im = zeros(ROIsize_xy(2),ROIsize_xy(1),1,length(chanList),length(timeList),outType);
end

for t=1:length(timeList)
    for c=1:length(chanList)
        if (~gotMips(t,c))
            for z=1:length(zList)
                tmpIm = MicroscopeData.Reader(imD,timeList, chanList, zList(z), outType, normalize, true, false, ROIstart_xy, ROIsize_xy);
                im(:,:,1,:,:) = max(im(:,:,1,:,:),tmpIm);
                
                if (~quiet)
                    cp.PrintProgress(i);
                    i = i+1;
                end
            end
        end
    end
end

if (~quiet)
    cp.ClearProgress();
end

imD.Dimensions(3) = 1;
end

