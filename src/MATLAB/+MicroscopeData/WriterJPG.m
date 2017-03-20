% WriterJPG(im, path, varargin)
% 
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% chanList - List of channels to write
% timeRange - Range min and max times to write
% verbose - Display verbose output and timing information

function WriterJPG(im, varargin)

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

if ( max(args.chanList) > args.imageData.NumberOfChannels)
    error('A value in chanList is greater than the number of channels in the image data!');
end

if ( args.timeRange(2) > args.imageData.NumberOfFrames )
    error('Specified time range is larger than the total number of frames.');
end

if ( size(im,4)~=length(args.chanList) )
    error('There are %d channels and %d channels to be written!',size(im,4),length(args.chanList));
end

if (args.verbose)
    iter = (args.timeRange(2)-args.timeRange(1)+1)*length(args.chanList)*size(im,3);
    
    cp = Utils.CmdlnProgress(iter,true,sprintf('Writing %s...',args.imageData.DatasetName));
    
    i=1;
end

tic
for t=args.timeRange(1):args.timeRange(2)
    for c=1:length(args.chanList)
        for z=1:size(im,3)
            chan = args.chanList(c);
            imFilename = [args.imageData.DatasetName,sprintf('_c%02d_t%04d_z%04d.jpg',chan,t,z)];
            
            im8 = ImUtils.ConvertType(im(:,:,z,chan,t),'uint8');
            imwrite(im8,fullfile(outDir,imFilename),'jpg');
            
            if (args.verbose)
                cp.PrintProgress(i);
                i = i+1;
            end
        end
    end
end

if (args.verbose)
    cp.ClearProgress();
    
    fprintf('Wrote %.0fMB in %s\n',...
        (prod(args.imageData.Dimensions)*args.imageData.NumberOfChannels*args.imageData.NumberOfFrames)/(1024*1024),...
        Utils.PrintTime(toc));
end
end
