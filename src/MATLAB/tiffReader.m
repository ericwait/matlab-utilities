% [IM, IMAGEDATA] = TIFFREADER(PATH, TIMELIST, CHANLIST, ZLIST, OUTTYPE, NORMALIZE, QUIET)
% ALL arguments are optional; pass in empty [] for the arguments that come
% prior to the one you would like to populate.
%
% PATH = the path to the meta data file
% TIMELIST = a list of frames that you would like to recive
% CHANLIST = a list of the channels you would like to recive
% ZLIST = a list of the stacks that you would like to recive
% OUTTYPE = the data type of image that you would like
% NORMALIZE = normalize each image per channel per frame. Meaning that for
%   each frame, every channel will be normalized independently.
% QUIET = if set to 1 then size stats will not be printed
%
% Outputs:
% IM = is a 5-D image of either the orginal type or the type requested.
% The data and can be indexed as (Y,X,Z,C,T) : c = channel, t = frame.
% IMAGEDATA = Optionaly the metadata can be the second output argument

function [im, varargout] = tiffReader(path, timeList, chanList, zList, outType, normalize, quiet)
im = [];

if (exist('tifflib') ~= 3)
    tifflibLocation = which('/private/tifflib');
    if (isempty(tifflibLocation))
        error('tifflib does not exits on this machine!');
    end
    copyfile(tifflibLocation,'.');
end

if (~exist('path','var') || isempty(path))
    path = [];
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

[imageData,path] = readMetadata(path);
if (isempty(imageData))
    warning('No image read!');
    if (nargout)
        varargout{1} = [];
    end
    return
end

if (isempty(chanList))
    chanList = 1:imageData.NumberOfChannels;
end
if (isempty(timeList))
    timeList = 1:imageData.NumberOfFrames;
end
if (isempty(zList))
    zList = 1:imageData.ZDimension;
end

if (~exist(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'file'))
    warning('No image read!');
    if (nargout)
        varargout{1} = [];
    end
    return
end

imInfo = imfinfo(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'tif');
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
imageData.Type = inType;
imageData.ImInfo = imInfo;

convert = false;
if (~strcmpi(inType,outType) || normalize)
    convert = true;
    tempIm = zeros(imageData.YDimension,imageData.XDimension,length(zList),inType);
end

im = zeros(imageData.YDimension,imageData.XDimension,length(zList),length(chanList),length(timeList),outType);

if (quiet~=1)
    if (strcmpi(inType,outType))
        fprintf('Type:%s ',outType);
    else
        fprintf('Type:%s->%s ',inType,outType);
    end
    fprintf('(');
    fprintf('%d',size(im,2));
    fprintf(',%d',size(im,1));
    for i=3:length(size(im))
        fprintf(',%d',size(im,i));
    end

    if (strcmpi(inType,outType))
        fprintf(') %5.2fMB\n', (imageData.XDimension*imageData.YDimension*length(zList)*length(chanList)*length(timeList)*bytes)/(1024*1024));
    else
        fprintf(') %5.2fMB->%5.2fMB\n',...
            (imageData.XDimension*imageData.YDimension*length(zList)*length(chanList)*length(timeList)*(imInfo(1).BitDepth/8))/(1024*1024),...
            (imageData.XDimension*imageData.YDimension*length(zList)*length(chanList)*length(timeList)*bytes)/(1024*1024));
    end
end

if (~quiet)
    iter = length(timeList)*length(chanList)*length(zList);
    cp = CmdlnProgress(iter,true);
    i=1;
end

for t=1:length(timeList)
    for c=1:length(chanList)
        for z=1:length(zList)
            tiffObj = Tiff(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'r');
            if (convert)
                tempIm(:,:,z) = tiffObj.read();
            else
                im(:,:,z,c,t) = tiffObj.read();
            end
            
            tiffObj.close();
            
            if (~quiet)
                PrintProgress(cp,i);
                i = i+1;
            end
        end

        if (convert)
            im(:,:,:,c,t) = imageConvertNorm(tempIm,outType,normalize);
        end
    end
end

if (~quiet)
    ClearProgress(cp);
end

if (convert)
    clear tempIm;
end

if (nargout)
    varargout{1} = imageData;
end
end
