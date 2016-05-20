% [IM, IMAGEDATA] = MicroscopeData.Sandbox.ReaderH5([path], varargin)
%
% Optional Parameters (Key,Value pairs):
% 
% imageData
% chanList
% timeRange
% roi_xyz
% outType
% normalize
% verbose
% prompt

function [im, imD] = ReaderH5(varargin)
im = [];

dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double'};

dataTypeSize = [1;2;4;8;
                1;2;4;8;
                4;8];

p = inputParser();
p.StructExpand = false;

% This is ridiculous, but we assume that the optional path is specified if
% length(varargin) is odd
if ( mod(length(varargin),2) == 1 )
    addOptional(p,'path','',@ischar);
else
    addParameter(p,'path','',@ischar);
end

addParameter(p,'imageData',[],@isstruct);

addParameter(p,'chanList',[],@isvector);
addParameter(p,'timeRange',[],@(x)(numel(x)==2));
addParameter(p,'roi_xyz',[],@(x)(size(x)==[2,3]));

addParameter(p,'outType',[],@(x)(any(strcmp(x,dataTypeLookup))));
addParameter(p,'normalize',false,@islogical);

addParameter(p,'verbose',false,@islogical);
addParameter(p,'prompt',[],@islogical);

parse(p,varargin{:});
args = p.Results;

if ( isempty(args.imageData) )
    imD = MicroscopeData.ReadMetadata(args.path,args.prompt);
else
    imD = args.imageData;
end

if (isempty(imD))
    warning('No image read!');
    return
end

path = imD.imageDir;

if (isempty(args.chanList))
    args.chanList = 1:imD.NumberOfChannels;
end

if (isempty(args.timeRange))
    args.timeRange = [1 imD.NumberOfFrames];
end

if (isempty(args.roi_xyz))
    args.roi_xyz = [1 1 1; imD.Dimensions];
end

if (~exist(fullfile(path,[imD.DatasetName '.h5']),'file'))
    warning('No image to read!');
    return
end

inType = class(h5read(fullfile(path,[imD.DatasetName '.h5']),'/Data',[1 1 1 1 1],[1 1 1 1 1]));
chkIdx = find(strcmp(inType,dataTypeLookup));
if ( isempty(chkIdx) )
    error('Unsupported image type!');
end

inBytes = dataTypeSize(chkIdx);

if ( isempty(args.outType) )
    args.outType = inType;
elseif (strcmp(args.outType,'logical'))
    bytes=1;
elseif ( ~any(strcmp(args.outType,dataTypeLookup)) )
    error('Unsupported output type!');
end

outIdx = find(strcmp(args.outType,dataTypeLookup));
if ( ~isempty(outIdx) )
    bytes = dataTypeSize(outIdx);
end

if (~isfield(imD,'PixelFormat'))
    imD.PixelFormat = inType;
elseif (strcmpi(inType,args.outType) && strcmpi(imD.PixelFormat,'logical'))
    args.outType = 'logical';
end

convert = ~strcmpi(inType,args.outType) || args.normalize;
imSize = [diff(Utils.SwapXY_RC(args.roi_xyz),1)+1,length(args.chanList),(args.timeRange(2)-args.timeRange(1)+1)];
if (~strcmpi(args.outType,'logical'))
    im = zeros(imSize, args.outType);
else
    im = false(imSize);
end

if ( args.verbose )
%     fprintf('Reading (%d,%d,%d,%d,%d) %s %5.2fMB --> Into (%d,%d,%d,%d,%d) %s %5.2fMB\n',...
%         imD.Dimensions(1),imD.Dimensions(2),length(zRange),length(chanList),length(timeRange),inType,...
%         (imD.Dimensions(1)*imD.Dimensions(2)*length(zRange)*length(chanList)*length(timeRange)*inBytes)/(1024*1024),...
%         size(im,2),size(im,1),size(im,3),size(im,4),size(im,5),outType,...
%         (numel(im)*bytes)/(1024*1024));
end

if ( convert )
    for c=1:length(args.chanList)
        for t=args.timeRange(1):imSize(4)
            tempIm = h5read(fullfile(path,[imD.DatasetName '.h5']),'/Data', [Utils.SwapXY_RC(args.roi_xyz(1,:)) args.chanList(c) t], [imSize(1:3) 1 1]);
            im(:,:,:,c,t) = ImUtils.ConvertType(tempIm,args.outType,args.normalize);
        end
    end
    
    clear tempIm;
else
    for c=1:length(args.chanList)
        im(:,:,:,c,:) = h5read(fullfile(path,[imD.DatasetName '.h5']),'/Data', [Utils.SwapXY_RC(args.roi_xyz(1,:)) args.chanList(c) args.timeRange(1)], [imSize(1:3) 1 imSize(5)]);
    end
end

imD.Dimensions = Utils.SwapXY_RC(imSize(1:3));
imD.NumberOfChannels = size(im,4);
imD.NumberOfFrames = size(im,5);

if (isfield(imD,'ChannelNames') && ~isempty(imD.ChannelNames))
    imD.ChannelNames = imD.ChannelNames(args.chanList)';
else
    imD.ChannelNames = {};
end
if (isfield(imD,'ChannelColors') && ~isempty(imD.ChannelColors))
    imD.ChannelColors = imD.ChannelColors(args.chanList,:);
else
    imD.ChannelColors = [];
end
end
