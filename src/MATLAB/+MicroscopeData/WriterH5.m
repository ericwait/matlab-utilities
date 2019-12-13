% WriterH5(im, path, varargin)
% 
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% chanList - List of channels to write
% timeRange - Range min and max times to write
% roi_xyz - x,y,z min and max roi to write
% imVersion - open the version of the image (e.g. Original, MIP, Processed)
%       Default is 'Original'
% verbose - Display verbose output and timing information

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
addParameter(p,'roi_xyz',[],@(x)(all(size(x)==[2,3])));
addParameter(p,'imVersion','Original',@ischar);

addParameter(p,'verbose',false,@islogical);

parse(p,varargin{:});
args = p.Results;

% If a path is specified we will use that instead of imageDir in matadata
[outDir,datasetName] = MicroscopeData.Helper.ParsePathArg(args.path,'.h5');

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

MicroscopeData.CreateMetadata(outDir,args.imageData, 'verbose',args.verbose);

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
   writeMIP = setFields(args,fileName,outType);
else
    info = h5info(fileName);
    if (~any(strcmp(args.imVersion,{info.Groups.Datasets.Name})))
        writeMIP = setFields(args,fileName,outType);
    else
        inType = class(h5read(fileName,['/Images/',args.imVersion],[1 1 1 1 1],[1 1 1 1 1]));
        writeMIP = true;
        if (~strcmp(inType,outType))
            error('You are trying to write to an existing file that holds a different data type %s-->%s',inType,outType);
        end
    end
end

if (isfield(args.imageData,'TimeStampDelta'))
    args.imageData = rmfield(args.imageData,'TimeStampDelta');
end
h5writeatt(fileName,'/','Metadata',Utils.CreateJSON(args.imageData,false));

imSize = [diff(Utils.SwapXY_RC(args.roi_xyz),1)+1, length(args.chanList), (args.timeRange(2)-args.timeRange(1)+1)];
if (length(args.chanList)==args.imageData.NumberOfChannels)
    h5write(fileName,['/Images/',args.imVersion],im, [Utils.SwapXY_RC(args.roi_xyz(1,:)),1,args.timeRange(1)],[imSize(1:3),args.imageData.NumberOfChannels,imSize(5)]);
    if (writeMIP)
        h5write(fileName,['/Images/',args.imVersion,'_MIP'],max(im,[],3), [Utils.SwapXY_RC(args.roi_xyz(1,1:2)),1,1,args.timeRange(1)],[imSize(1:2),1,args.imageData.NumberOfChannels,imSize(5)]);
    end
else
    for c=1:length(args.chanList)
        h5write(fileName,['/Images/',args.imVersion],im(:,:,:,c,:), [Utils.SwapXY_RC(args.roi_xyz(1,:)),args.chanList(c),args.timeRange(1)],[imSize(1:3),1,imSize(5)]);
        if (writeMIP)
            h5write(fileName,['/Images/',args.imVersion,'_MIP'],max(im(:,:,:,c,:),[],3), [Utils.SwapXY_RC(args.roi_xyz(1,1:2)),1,args.chanList(c),args.timeRange(1)],[imSize(1:2),1,1,imSize(5)]);
        end
    end
end

if (args.verbose)
    f = dir(fileName);
    fprintf('Wrote %s %.0fMB-->%.0fMB in %s\n',...
        args.imVersion,...
        (bytes*prod(args.imageData.Dimensions)*args.imageData.NumberOfChannels*args.imageData.NumberOfFrames)/(1024*1024),...
        f.bytes/(1024*1024),Utils.PrintTime(toc));
end
end

function [writeMIP] = setFields(args,fileName,outType)
    totalImSize = Utils.SwapXY_RC([args.imageData.Dimensions args.imageData.NumberOfChannels args.imageData.NumberOfFrames]);
    chunkSize = min(totalImSize,[64,64,8,1,1]);
    h5create(fileName,['/Images/',args.imVersion],totalImSize, 'DataType',outType, 'ChunkSize',chunkSize, 'Deflate',2);
    
    mipImSize = Utils.SwapXY_RC([args.imageData.Dimensions(1:2) 1 args.imageData.NumberOfChannels args.imageData.NumberOfFrames]);
    writeMIP = prod(mipImSize)~=prod(totalImSize);
    if (writeMIP)
        mipchunkSize = min(mipImSize,[64,64,1,1,1]);
        h5create(fileName,['/Images/',args.imVersion,'_MIP'], mipImSize, 'DataType',outType, 'ChunkSize',mipchunkSize, 'Deflate',2);
    end
end
