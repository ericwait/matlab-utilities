% WriterBinary(im, path, varargin)
% 
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% timeRange - Range min and max times to write
% verbose - Display verbose output and timing information

function WriterBinary(im, varargin)

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

addParameter(p,'timeRange',[],@(x)(numel(x)==2));

addParameter(p,'verbose',false,@islogical);

parse(p,varargin{:});
args = p.Results;

% If a path is specified we will use that instead of imageDir in matadata
[outDir,datasetName] = MicroscopeData.Helper.ParsePathArg(args.path,'.jpg');

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
if ~exist(outDir,'dir')
    mkdir(outDir)
end     

if ( isempty(args.timeRange) )
    args.timeRange = [1 args.imageData.NumberOfFrames];
end

if ( args.timeRange(2) > args.imageData.NumberOfFrames )
    error('Specified time range is larger than the total number of frames.');
end

if (args.verbose)
    iter = (args.timeRange(2)-args.timeRange(1)+1)*size(im,4)*size(im,3);
    
    cp = Utils.CmdlnProgress(iter,true,sprintf('Writing %s...',args.imageData.DatasetName));
    
    i=1;
end

tic
txPack=4;
NumPack=ceil(size(im,4)/txPack);
tList = args.timeRange(1):args.timeRange(2);
for tIdx=1:length(tList)
    for pack=1:NumPack
        imFilename = [args.imageData.DatasetName,sprintf('_p%02d_t%04d.lbin',pack,tList(tIdx))];
        
        chanEnd = min((pack-1)*NumPack + txPack,size(im,4));
        chans = ((pack-1)*txPack + 1):chanEnd;

        im8 = ImUtils.ConvertType(im(:,:,:,:,tIdx),'uint8',false);
        imPacked = permute(im8(:,:,:,chans),[4,2,1,3]);
        
        fid = fopen(fullfile(outDir,imFilename),'wb');
        
        fwrite(fid, size(imPacked,1), 'uint16',0,'ieee-be');
        fwrite(fid, size(imPacked,2), 'uint16',0,'ieee-be');
        fwrite(fid, size(imPacked,3), 'uint16',0,'ieee-be');
        fwrite(fid, size(imPacked,4), 'uint16',0,'ieee-be');
        
        fwrite(fid, imPacked(:), 'uint8');
        
        fclose(fid);

        if (args.verbose)
            cp.PrintProgress(i);
            i = i+1;
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
