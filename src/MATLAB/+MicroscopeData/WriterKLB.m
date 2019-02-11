% WriterKLB(im, path, varargin)
% 
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% chanList - List of channels to write
% timeRange - Range min and max times to write
% verbose - Display verbose output and timing information

function WriterKLB(im, varargin)
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
    addParameter(p,'multiFile',false,@islogical);
    addParameter(p,'filePerT',false,@islogical);
    addParameter(p,'filePerC',false,@islogical);

    addParameter(p,'verbose',false,@islogical);

    parse(p,varargin{:});
    args = p.Results;

    % If a path is specified we will use that instead of imageDir in matadata
    [outDir,datasetName] = MicroscopeData.Helper.ParsePathArg(args.path,'.klb');

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

    bytes = MicroscopeData.Helper.GetBytesPerVoxel(im);

    if (~isfield(args.imageData,'PixelFormat'))
        w = whos('im');
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

    MicroscopeData.CreateMetadata(outDir,args.imageData,args.verbose);

    if ( isempty(args.chanList) )
        args.chanList = 1:args.imageData.NumberOfChannels;
    end
    if (args.imageData.NumberOfChannels>length(args.chanList))
        args.filePerC = true;
    end

    if ( isempty(args.timeRange) )
        args.timeRange = [1 args.imageData.NumberOfFrames];
    end
    if (args.imageData.NumberOfFrames>length(args.timeRange(1):args.timeRange(2)))
        args.filePerT = true;
    end

    if ( max(args.chanList) > args.imageData.NumberOfChannels)
        error('A value in chanList is greater than the number of channels in the image data!');
    end

    if ( args.timeRange(2) > args.imageData.NumberOfFrames )
        error('Specified time range is larger than the total number of frames.');
    end

    if ( size(im,4)~=length(args.chanList) )
        error('There are %d channels in the image but only %d channels are to be written!',size(im,4),length(args.chanList));
    end

    %save metadata for the type we want not the type we have to store
    if (strcmp(args.imageData.PixelFormat,'logical'))
        outType = 'uint8';
        im = ImUtils.ConvertType(im,'uint8',false);
    else
        outType = args.imageData.PixelFormat;
    end

    if (~strcmp(args.imageData.PixelFormat,outType))
        im = ImUtils.ConvertType(im,outType,false);
    end
    
    MicroscopeData.KLB_(im,args.imageData.DatasetName,outDir,args.imageData.PixelPhysicalSize,args.chanList,args.timeRange,args.filePerT,args.filePerC,args.verbose);
end
