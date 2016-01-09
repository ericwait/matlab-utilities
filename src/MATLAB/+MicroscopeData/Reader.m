% [IM, IMAGEDATA] = MicroscopeData.Reader(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
function [im, imD] = Reader(pathOrImageData, timeList, chanList, zList, outType, normalize, quiet, prompt, ROIstart_xy, ROIsize_xy)
im = [];
imD = [];

if (exist('tifflib') ~= 3)
    tifflibLocation = which('/private/tifflib');
    if (isempty(tifflibLocation))
        error('tifflib does not exits on this machine!');
    end
    copyfile(tifflibLocation,'.');
end

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

useROI = any(ROIsize_xy ~= imD.Dimensions(1:2));

if (isempty(chanList))
    chanList = 1:imD.NumberOfChannels;
end
if (isempty(timeList))
    timeList = 1:imD.NumberOfFrames;
end
if (isempty(zList))
    zList = 1:imD.Dimensions(3);
end

if (~exist(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imD.DatasetName,1,1,1)),'file'))
    warning('No image read!');
    return
end

imInfo = imfinfo(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imD.DatasetName,1,1,1)),'tif');
if (isempty(outType))
    bytes = imInfo(1).BitDepth/8;
    if (imInfo(1).BitDepth==8)
        outType = 'uint8';
    elseif (imInfo(1).BitDepth==16)
        outType = 'uint16';
    elseif (imInfo(1).BitDepth==32)
        outType = 'uint32';
    else
        outType = 'double';
    end
elseif (strcmp(outType,'double'))
    bytes=8;
    outType = 'double';
elseif (strcmp(outType,'uint32') || strcmp(outType,'int32') || strcmp(outType,'single'))
    bytes=4;
elseif (strcmp(outType,'uint16') || strcmp(outType,'int16'))
    bytes=2;
elseif (strcmp(outType,'uint8'))
    bytes=1;
elseif (strcmp(outType,'logical'))
    bytes=1/8;
else
    error('Unsupported output type!');
end

if (isfield(imInfo,'SampleFormat'))
    switch imInfo(1).SampleFormat
        case 'Unsigned integer'
            frmt = 1;
        case 'Integer'
            frmt = 2;
        case 'IEEE floating point'
            frmt = 3;
        otherwise
            error('Unsupported input type!');
    end
else
    frmt = 1;
end
switch imInfo(1).BitDepth
    case 8
        if (frmt==1)
            inType = 'uint8';
        elseif (frmt==2)
            inType = 'int8';
        else
            error('Unsupported input type!');
        end
    case 16
        if (frmt==1)
            inType = 'uint16';
        elseif (frmt==2)
            inType = 'int16';
        else
            error('Unsupported input type!');
        end
    case 32
        if (frmt==1)
            inType = 'uint32';
        elseif (frmt==2)
            inType = 'int32';
        elseif (frmt==3)
            inType = 'single';
        else
            error('Unsupported input type!');
        end
    case 64
        if (frmt==3)
            inType = 'double';
        else
            error('Unsupported input type!');
        end
    otherwise
        error('Unsupported input type!');
end

convert = false;
if (~strcmpi(inType,outType) || normalize)
    convert = true;
    tempIm = zeros(imD.Dimensions(2),imD.Dimensions(1),length(zList),inType);
end

if (~strcmpi(outType,'logical'))
    im = zeros(ROIsize_xy(2),ROIsize_xy(1),length(zList),length(chanList),length(timeList),outType);
else
    im = false(ROIsize_xy(2),ROIsize_xy(1),length(zList),length(chanList),length(timeList));
end

if (quiet~=true)
    fprintf('Reading (%d,%d,%d,%d,%d) %s %5.2fMB --> Into (%d,%d,%d,%d,%d) %s %5.2fMB\n',...
        imD.Dimensions(1),imD.Dimensions(2),length(zList),length(chanList),length(timeList),inType,...
        (imD.Dimensions(1)*imD.Dimensions(2)*length(zList)*length(chanList)*length(timeList)*bytes)/(1024*1024),...
        size(im,2),size(im,1),size(im,3),size(im,4),size(im,5),outType,...
        (numel(im)*(imInfo(1).BitDepth/8))/(1024*1024));
end

if (~quiet)
    iter = length(timeList)*length(chanList)*length(zList);
    cp = Utils.CmdlnProgress(iter,true);
    i=1;
end

for t=1:length(timeList)
    for c=1:length(chanList)
        for z=1:length(zList)
            tiffObj = Tiff(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imD.DatasetName,chanList(c),timeList(t),zList(z))),'r');
            if (convert || useROI)
                tempIm(:,:,z) = tiffObj.read();
            else
                im(:,:,z,c,t) = tiffObj.read();
            end

            tiffObj.close();

            if (~quiet)
                cp.PrintProgress(i);
                i = i+1;
            end
        end

        if (convert)
            im(:,:,:,c,t) = ImUtils.ConvertType(...
                tempIm(ROIstart_xy(2):ROIstart_xy(2)+ROIsize_xy(2)-1,ROIstart_xy(1):ROIstart_xy(1)+ROIsize_xy(1)-1,:),...
                outType,normalize);
        elseif (useROI)
            im(:,:,:,c,t) = tempIm(ROIstart_xy(2):ROIstart_xy(2)+ROIsize_xy(2)-1,ROIstart_xy(1):ROIstart_xy(1)+ROIsize_xy(1)-1,:);
        end
    end
end

if (~quiet)
    cp.ClearProgress();
end

if (convert)
    clear tempIm;
end

imD.Dimensions = [size(im,2),size(im,1),size(im,3)];
imD.NumberOfChannels = size(im,4);
imD.NumberOfFrames = size(im,5);
if (isfield('imD','ChannelName'))
    imD.ChannelNames = {imD.ChannelNames{chanList}}';
else
    imD.ChannelNames = {};
end
if (isfield('imD','ChannelColors'))
    imD.ChannelColors = imD.ChannelColors(chanList,:);
else
    imD.ChannelColors = [];
end
end
