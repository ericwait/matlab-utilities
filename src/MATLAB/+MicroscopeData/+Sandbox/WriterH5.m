% WriterH5(im, path, varargin)
% 
% Optional Parameters (Key,Value pairs):
% 
% datasetName
% imageData
% chanList
% timeRange
% roi_xyz
% verbose

function WriterH5(im, varargin)

dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double';
                  'logical'};

dataTypeSize = [1;2;4;8;
                1;2;4;8;
                4;8;
                1];

p = inputParser();
p.StructExpand = false;

% This is ridiculous, but we assume that the optional path is specified if
% length(varargin) is odd
if ( mod(length(varargin),2) == 1 )
    addOptional(p,'path','',@ischar);
else
    addParameter(p,'path','',@ischar);
end

addParameter(p,'datasetName',[],@ischar);
addParameter(p,'imageData',[],@isstruct);

addParameter(p,'chanList',[],@isvector);
addParameter(p,'timeRange',[],@(x)(numel(x)==2));
addParameter(p,'roi_xyz',[],@(x)(size(x)==[2,3]));

addParameter(p,'verbose',false,@islogical);

parse(p,varargin{:});
args = p.Results;

outDir = '';
datasetName = '';
if ( ~isempty(args.path) )
    [outDir,chkFile,chkExt] = fileparts(args.path);
    if ( ~isempty(chkExt) )
        datasetName = chkFile;
    else
        outDir = args.path;
    end
end

if ( ~isempty(args.datasetName) )
    datasetName = args.datasetName;
end

if ( isempty(args.imageData) && isempty(datasetName) )
    error('Either imageData, a datasetName, or a full file path must be provided!');
end

if ( isempty(args.imageData) )
    args.imageData.DatasetName = datasetName;

    chkSize = size(im);
    args.imageData.Dimensions = Utils.SwapXY_RC(chkSize(1:3));
    args.imageData.NumberOfChannels = chkSize(4);
    args.imageData.NumberOfFrames = chkSize(5);

    args.imageData.PixelPhysicalSizes = [1.0, 1.0, 1.0];
elseif ( ~isempty(datasetName) )
    args.imageData.DatasetName = datasetName;
end

% Remove any quotes from the dataset name
args.imageData.DatasetName = strrep(args.imageData.DatasetName,'"','');

w = whos('im');
typeIdx = find(strcmp(w.class,dataTypeLookup));
if ( ~isempty(typeIdx) )
    bytes = dataTypeSize(typeIdx);
else
    error('Unsuported pixel type!');
end

if (~isfield(args.imageData,'PixelFormat'))
    args.imageData.PixelFormat = w.class;
end

if ( isempty(outDir) )
    outDir = '.';
end

outDir = strrep(outDir, '"','');
% fix if image type if the image is different
if (~isfield(args.imageData,'PixelFormat'))
    args.imageData.PixelFormat = class(im);
elseif (~strcmp(args.imageData.PixelFormat,class(im)))
    args.imageData.PixelFormat = class(im);
end

MicroscopeData.CreateMetadata(outDir,args.imageData,~args.verbose);

if ( isempty(args.chanList) )
    args.chanList = 1:args.imageData.NumberOfChannels;
end

if ( isempty(args.timeRange) )
    args.timeRange = [1 args.imageData.NumberOfFrames];
end

if ( isempty(args.roi_xyz) )
    args.roi_xyz = [1 1 1; args.imageData.Dimensions];
end

if ( max(args.chanList) > args.imageData.NumberOfChannels)
    error('A value in chanList is greater than the number of channels in the image data!');
end

if ( args.timeRange(2) > args.imageData.NumberOfFrames )
    error('Specified time range is larger than the total number of frames.');
end

if ( any(args.roi_xyz(2,:) > args.imageData.Dimensions) )
    error('Specified roi is larger than imageData size.');
end

if ( size(im,4)~=length(args.chanList) )
    error('There are %d channels and %d channels to be written!',size(im,4),length(args.chanList));
end

tic

%save metadata for the type we want not the type we have to store
if (strcmp(args.imageData.PixelFormat,'logical'))
    outType = 'uint8';
    im = ImUtils.ConvertType(im,'uint8',false);
else
    outType = args.imageData.PixelFormat;
end

fileName = fullfile(outDir,[args.imageData.DatasetName '.h5']);
if ( ~exist(fileName,'file') )
    totalImSize = Utils.SwapXY_RC([args.imageData.Dimensions args.imageData.NumberOfChannels args.imageData.NumberOfFrames]);
    chunkSize = min(totalImSize,[64,64,8,1,1]);
    
    h5create(fileName,'/Data',totalImSize, 'DataType',outType, 'ChunkSize',chunkSize, 'Deflate',2)
else
    inType = class(h5read(fullfile(path,[imD.DatasetName '.h5']),'/Data',[1 1 1 1 1],[1 1 1 1 1]));
    if (~strcmp(inType,outType))
        error('You are trying to write to an existing file that holds a different data type %s-->%s',inType,outType);
    end
end

h5writeatt(fileName,'/','Metadata',Utils.CreateJSON(args.imageData,false));

imSize = [diff(Utils.SwapXY_RC(args.roi_xyz),1)+1, length(args.chanList), (args.timeRange(2)-args.timeRange(1)+1)];
if (length(args.chanList)==args.imageData.NumberOfChannels)
    h5write(fileName,'/Data',im, [Utils.SwapXY_RC(args.roi_xyz(1,:)),1,args.timeRange(1)],[imSize(1:3),args.imageData.NumberOfChannels,imSize(5)]);
else
    for c=1:length(args.chanList)
        h5write(fileName,'/Data',im(:,:,:,c,:), [Utils.SwapXY_RC(args.roi_xyz(1,:)),args.chanList(c),args.timeRange(1)],[imSize(1:3),1,imSize(5)]);
    end
end

if (args.verbose)
    f = dir(fileName);
    fprintf('Wrote %.0fMB-->%.0fMB in %s\n',...
        (bytes*prod(args.imageData.Dimensions)*args.imageData.NumberOfChannels*args.imageData.NumberOfFrames)/(1024*1024),...
        f.bytes/(1024*1024),Utils.PrintTime(toc));
end
end

