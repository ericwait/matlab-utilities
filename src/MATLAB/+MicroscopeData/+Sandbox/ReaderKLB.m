% [IM, IMAGEDATA] = MicroscopeData.Sandbox.ReaderKLB(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
function [im, imD] = ReaderKLB(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
im = [];
imD = [];

if (~exist('pathOrImageData','var'))
    pathOrImageData = [];
end
if (~exist('timeList','var') || isempty(timeList))
    timeList = [];
end
if (~exist('chanList','var') || isempty(chanList))
    chanList = [];
end
if (~exist('zList','var') || isempty(zList))
    zList = [];
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
if (~exist('ROIstart_xy','var') || isempty(ROIstart_xy))
    ROIstart_xy = [1,1];
end

ROIstart_xy = max(ROIstart_xy,[1,1]);

if (nargin==0)
    prompt = true;
elseif (~exist('prompt','var'))
    prompt = [];
end

if (~isstruct(pathOrImageData))
    [imD,path,seriesNum,filePath] = MicroscopeData.ReadMetadata(pathOrImageData,prompt);
    if (~isempty(seriesNum))
        [root,fileName,ext] = fileparts(filePath);
        im = MicroscopeData.Original.ReadImages(root, [fileName,ext], seriesNum);

        return
    end
else
    imD = pathOrImageData;
    path = imD.imageDir;
    dataSetNum = [];
end

if (isempty(imD))
    warning('No image read!');
    return
end

if (~exist('ROIsize_xy','var') || isempty(ROIsize_xy))
    ROIsize_xy(1) = length(ROIstart_xy(1):imD.Dimensions(1));
    ROIsize_xy(2) = length(ROIstart_xy(2):imD.Dimensions(2));
end

if (any(ROIsize_xy<1))
    warning('ROIsize resulted in no area being read!');
end

if (ROIstart_xy(1) + ROIsize_xy(1) -1 > imD.Dimensions(1))
    ROIsize_xy(1) = length(ROIstart_xy(1):imD.Dimensions(1));
    if (~quiet)
        warning('ROI_x went out side of the original image, using a new size!');
    end
end

if (ROIstart_xy(2) + ROIsize_xy(2) -1 > imD.Dimensions(2))
    ROIsize_xy(2) = length(ROIstart_xy(2):imD.Dimensions(2));
    if (~quiet)
        warning('ROI_y went out side of the original image, using a new size!');
    end
end

if (isempty(chanList))
    chanList = 1:imD.NumberOfChannels;
end
if (isempty(timeList))
    timeList = 1:imD.NumberOfFrames;
end
if (isempty(zList))
    zList = 1:imD.Dimensions(3);
end

if (~exist(fullfile(path,sprintf('%s_c%02d.klb',imD.DatasetName,1)),'file'))
    warning('No image to read!');
    return
end

dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double'};

dataTypeSize = [1;2;4;8;
                1;2;4;8;
                4;8];

header = MicroscopeData.Sandbox.KLB.readKLBheader(fullfile(path,sprintf('%s_c%02d.klb',imD.DatasetName,1)));
inBytes = dataTypeSize(header.dataType+1);

inType = dataTypeLookup{header.dataType+1};
if (isempty(outType))
    outType = inType;
elseif (strcmp(outType,'logical'))
    bytes=1/8;
elseif ( ~any(strcmp(outType,dataTypeLookup)) )
    error('Unsupported output type!');
end

outIdx = find(strcmp(outType,dataTypeLookup));
if ( ~isempty(outIdx) )
    bytes = dataTypeSize(outIdx);
end

if (~isfield(imD,'PixelFormat'))
    imD.PixelFormat = inType;
elseif (strcmpi(inType,outType) && strcmpi(imD.PixelFormat,'logical'))
    outType = 'logical';
end

convert = ~strcmpi(inType,outType) || normalize;
if (~strcmpi(outType,'logical'))
    im = zeros(ROIsize_xy(2),ROIsize_xy(1),length(zList),length(chanList),length(timeList),outType);
else
    im = false(ROIsize_xy(2),ROIsize_xy(1),length(zList),length(chanList),length(timeList));
end

if (quiet~=true)
    fprintf('Reading (%d,%d,%d,%d,%d) %s %5.2fMB --> Into (%d,%d,%d,%d,%d) %s %5.2fMB\n',...
        imD.Dimensions(1),imD.Dimensions(2),length(zList),length(chanList),length(timeList),inType,...
        (imD.Dimensions(1)*imD.Dimensions(2)*length(zList)*length(chanList)*length(timeList)*inBytes)/(1024*1024),...
        size(im,2),size(im,1),size(im,3),size(im,4),size(im,5),outType,...
        (numel(im)*bytes)/(1024*1024));
end

roi = [ROIstart_xy(2) ROIstart_xy(1) min(zList) 1 min(timeList);
       ROIstart_xy(2)+ROIsize_xy(2)-1 ROIstart_xy(1)+ROIsize_xy(1)-1 max(zList) 1 max(timeList)];

zSubIdx = zList - min(zList) + 1;
tSubIdx = timeList - min(timeList) + 1;

if ( convert )
    roiT = roi;
    for c=1:length(chanList)
        for t=1:length(timeList)
            roiT(:,5) = timeList(t);
            
            tempIm = MicroscopeData.Sandbox.KLB.readKLBroi(fullfile(path,sprintf('%s_c%02d.klb',imD.DatasetName,chanList(c))), roiT);
            tempIm = tempIm(:,:,zSubIdx);
            
            im(:,:,:,c,t) = ImUtils.ConvertType(tempIm,outType,normalize);
        end
    end
    
    clear tempIm;
else
    for c=1:length(chanList)
        im(:,:,:,c,:) = MicroscopeData.Sandbox.KLB.readKLBroi(fullfile(path,sprintf('%s_c%02d.klb',imD.DatasetName,chanList(c))), roi);
    end
end

imD.Dimensions = [size(im,2),size(im,1),size(im,3)];
imD.NumberOfChannels = size(im,4);
imD.NumberOfFrames = size(im,5);
if (isfield(imD,'ChannelNames') && ~isempty(imD.ChannelNames))
    imD.ChannelNames = {imD.ChannelNames{chanList}}';
else
    imD.ChannelNames = {};
end
if (isfield(imD,'ChannelColors') && ~isempty(imD.ChannelColors))
    imD.ChannelColors = imD.ChannelColors(chanList,:);
else
    imD.ChannelColors = [];
end
end
