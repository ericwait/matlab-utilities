% WriterTif(im, path, varargin)
% 
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% chanList - List of channels to write
% timeRange - Range min and max times to write
% verbose - Display verbose output and timing information

function WriterTif(im, varargin)

    dataTypeLookup = {'uint8';'uint16';'uint32'
                      'int8';'int16';'int32'};

    dataTypeSize = [1;2;4;8;
                    1;2;4;8;
                    4;8;
                    1];

    p = inputParser();
    p.StructExpand = false;

    % This is ridiculous, but we assume that the optional path is specified if
    % length(varargin) is odd
    if ( mod(length(varargin),2) == 1 )
        addOptional(p,'path','');
    else
        addParameter(p,'path','');
    end

    addParameter(p,'datasetName',[],@ischar);
    addParameter(p,'imageData',[],@isstruct);

    addParameter(p,'chanList',[],@isvector);
    addParameter(p,'timeRange',[],@(x)(numel(x)==2));
    addParameter(p,'multiFile',false,@islogical);
    addParameter(p,'filePerZ',false,@islogical);

    addParameter(p,'verbose',false,@islogical);

    parse(p,varargin{:});
    args = p.Results;

    % If a path is specified we will use that instead of imageDir in matadata
    [outDir,datasetName] = MicroscopeData.Helper.ParsePathArg(args.path,'.tif');

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
    end
    if ( ~isempty(datasetName) )
        args.imageData.DatasetName = datasetName;
    end
    if (isempty(outDir) && isfield(args.imageData,'imageDir') && ~isempty(args.imageData.imageDir))
        outDir = args.imageData.imageDir;
    end

    % Remove any quotes from the dataset name
    args.imageData.DatasetName = strrep(args.imageData.DatasetName,'"','');

    w = whos('im');
    typeIdx = find(strcmp(w.class,dataTypeLookup));
    if ( ~isempty(typeIdx) )
        bytes = dataTypeSize(typeIdx);
    else
        switch w.class
            case 'logical'
                im = ImUtils.ConvertType(im,'uint8');
                warning('This image was converted to uint8 prior to writing!');
            case 'single'
                im = ImUtils.ConvertType(im,'uint16',true);
                warning('This image was converted to uint16 prior to writing! Each channel was normalized independently. If this is undesirable, convert the image prior to calling WriterTif.');
            case 'double'
                im = ImUtils.ConvertType(im,'uint32',true);
                warning('This image was converted to uint32 prior to writing! Each channel was normalized independently. If this is undesirable, convert the image prior to calling WriterTif.');
        end
        w = whos('im');
        typeIdx = find(strcmp(w.class,dataTypeLookup));
        bytes = dataTypeSize(typeIdx);
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

    if ( max(args.chanList) > args.imageData.NumberOfChannels)
        error('A value in chanList is greater than the number of channels in the image data!');
    end

    if ( args.timeRange(2) > args.imageData.NumberOfFrames )
        error('Specified time range is larger than the total number of frames.');
    end

    if ( size(im,4)~=length(args.chanList) )
        error('There are %d channels and %d channels to be written!',size(im,4),length(args.chanList));
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

    tags.ImageLength = size(im,1);
    tags.ImageWidth = size(im,2);
    tags.RowsPerStrip = size(im,2);
    tags.Photometric = Tiff.Photometric.MinIsBlack;
    tags.ExtraSamples = Tiff.ExtraSamples.Unspecified;
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tags.SamplesPerPixel = 1;
    tags.Compression = Tiff.Compression.LZW;
    tags.Software = 'MATLAB';
    tags.BitsPerSample = bytes * 8;
    
    writeType = 'w';
    if (args.filePerZ)
        if (0.9*(2^32-1)<bytes*size(im,1)*size(im,2))
            writeType = 'w8';
        end
    else
        if (0.9*(2^32-1)<bytes*size(im,1)*size(im,2)*size(im,3))
            writeType = 'w8';
        end
    end
    
    prgs = Utils.CmdlnProgress(size(im,4)*size(im,5),true,['Writing ', args.imageData.DatasetName]);
    for t=1:size(im,5)
        for c=1:size(im,4)
            if (args.filePerZ)
                for z=1:size(im,3)
                    tiffObj = Tiff(fullfile(outDir,[args.imageData.DatasetName,sprintf('_c%02d_t%04d_z%04d.tif',args.chanList(c),args.timeRange(1)+t-1,z)]),writeType);
                    tiffObj.setTag(tags);
                    tiffObj.write(im(:,:,z,c,t),tags);
                    tiffObj.close();
                end
            else
                MicroscopeData.Write3Dtif(im(:,:,:,c,t),sprintf('%s_c%02d_t%04d',args.imageData.DatasetName,args.chanList(c),args.timeRange(1)+t-1),outDir);
%                 tiffObj = Tiff(fullfile(outDir,[args.imageData.DatasetName,sprintf('_c%02d_t%04d.tif',args.chanList(c),args.timeRange(1)+t-1)]),writeType);
%                 for z=1:size(im,3)
%                     tiffObj.setTag(tags);
%                     tiffObj.write(im(:,:,z,c,t),tags);
%                     tiffObj.writeDirectory();
%                 end
%                 tiffObj.close();
            end
            if (args.verbose)
                prgs.PrintProgress(c+(t-1)*size(im,4));
            end
        end
    end
    if (args.verbose)
        prgs.ClearProgress(true);
        w = whos('im');
        fprintf('Wrote %.0fMB\n',w.bytes/(1024*1024));
    end
end
