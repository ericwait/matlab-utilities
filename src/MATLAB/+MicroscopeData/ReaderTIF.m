% [IM, IMAGEDATA] = MicroscopeData.Reader([path], varargin)
%
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% chanList - List of channels to read
% timeRange - Range min and max times to read
% roi_xyz - x,y,z min and max roi to read
% outType - Desired output type, conversion is applied if different from image
% normalize - Normalize images on [0,1] per frame before conersion to output type
% verbose - Display verbose output and timing information
% prompt - False to completely disable prompts, true to force prompt, leave unspecified or empty for default prompt behavior
% promptTitle - Open dialog title in the case that prompting is required

function [im, imD] = ReaderTIF(varargin)
    im = [];

    dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                      'int8';'int16';'int32';'int64';
                      'single';'double';
                      'logical'};

    dataTypeSize = [1;2;4;8;
                    1;2;4;8;
                    4;8;
                    1];

    args = MicroscopeData.Helper.ParseReaderInputs(varargin{:});

    loadPath = '';
    if ( ~isempty(args.imageData) )
        loadPath = args.imageData.imageDir;
    elseif ( ~isempty(args.path) )
        loadPath = args.path;
    end

    if ( args.prompt )
        imD = MicroscopeData.ReadMetadata(loadPath,args.prompt,args.promptTitle);
    elseif ( isempty(args.imageData) )
        imD = MicroscopeData.ReadMetadata(loadPath,args.prompt,args.promptTitle);
    else
        imD = args.imageData;
    end

    if (isempty(imD))
        warning('No image read!');
        return
    end

    imPath = imD.imageDir;

    if (isempty(args.chanList))
        args.chanList = 1:imD.NumberOfChannels;
    end

    if (isempty(args.timeRange))
        args.timeRange = [1 imD.NumberOfFrames];
    end

    if (isempty(args.roi_xyz))
        args.roi_xyz = [1 1 1; imD.Dimensions];
    end

    if (isempty(args.normalize))
        args.normalize = false;
    end

    dList = dir(fullfile(imPath,[imD.DatasetName,'_c*_t*.tif']));
    if (isempty(dList))
        warning('No image to read!');
        return
    end

    useROI = (nnz(args.roi_xyz(:,1:2) ~= [1 1;imD.Dimensions(1:2)]) > 0);
    
    filePerZ = ~isempty(regexpi(dList(1).name,'.*_z\d+.tif'));

    inType = MicroscopeData.Helper.GetPixelTypeTIF(fullfile(imPath,dList(1).name));
    inIdx = find(strcmp(inType,dataTypeLookup));
    if ( ~isempty(inIdx) )
        inBytes = dataTypeSize(inIdx);
    else
        error('Unsupported image type!');
    end

    if (~isfield(imD,'PixelFormat'))
        imD.PixelFormat = inType;
    end

    if ( isempty(args.outType) )
        if (strcmp(imD.PixelFormat,'logical'))
            args.outType = 'logical';
        else
            args.outType = inType;
        end
    elseif ( ~any(strcmp(args.outType,dataTypeLookup)) )
        error('Unsupported output type!');
    end

    outIdx = find(strcmp(args.outType,dataTypeLookup));
    if ( ~isempty(outIdx) )
        outBytes = dataTypeSize(outIdx);
    end

    convert = ~strcmpi(inType,args.outType) || args.normalize;
    imSize = [diff(Utils.SwapXY_RC(args.roi_xyz),1)+1,length(args.chanList),(args.timeRange(2)-args.timeRange(1)+1)];
    if (args.getMIP)
        imSize(3) = 1;
    end
    if (~strcmpi(args.outType,'logical'))
        im = zeros(imSize, args.outType);
    else
        im = false(imSize);
    end

    if ( args.verbose )
        orgSize = [imD.Dimensions(1),imD.Dimensions(2),imD.Dimensions(3),imD.NumberOfChannels,imD.NumberOfFrames];
        fprintf('Reading (%d,%d,%d,%d,%d) %s %5.2fMB --> Into (%d,%d,%d,%d,%d) %s %5.2fMB,',...
            orgSize(1),orgSize(2),orgSize(3),orgSize(4),orgSize(5),inType,...
            (prod(orgSize)*inBytes)/(1024*1024),...
            imSize(1),imSize(2),imSize(3),imSize(4),imSize(5),args.outType,...
            (prod(imSize)*outBytes)/(1024*1024));
    end

    iter = imSize(5)*length(args.chanList)*imSize(3);
    prgs = Utils.CmdlnProgress(iter,true,sprintf('Reading %s...',imD.DatasetName));

    for t=1:imSize(5)
        timeVal = t+args.timeRange(1)-1;
        for c=1:length(args.chanList)
            tempIm = zeros(imSize(1:3), inType);
            
            if (filePerZ)
                for z=1:imSize(3)
                    zVal = z+args.roi_xyz(1,3)-1;
                    
                    tifName = fullfile(imPath,sprintf('%s_c%02d_t%04d_z%04d.tif',imD.DatasetName,args.chanList(c),timeVal,zVal));
                    
                    tempIm(:,:,z) = MicroscopeData.ReadTiffImage(tifName);
                end
            else
                tifName = fullfile(imPath,sprintf('%s_c%02d_t%04d.tif',imD.DatasetName,args.chanList(c),timeVal));
                tempIm = MicroscopeData.ReadTiffImage(tifName);
            end
            
            if (useROI)
                tempIm = tempIm(args.roi_xyz(1,2):args.roi_xyz(2,2),args.roi_xyz(1,1):args.roi_xyz(2,1),args.roi_xyz(1,3):args.roi_xyz(2,3));
            end
            
            if (args.getMIP)
                tempIm = max(tempIm,[],3);
            end
            
            if (convert)
                tempIm = ImUtils.ConvertType(tempIm,args.outType,args.normalize);
            end
            
            im(1:size(tempIm,1),1:size(tempIm,2),1:size(tempIm,3),c,t) = tempIm;

            if ( args.verbose )
                prgs.PrintProgress(c+(t-1)*length(args.chanList));
            end
        end
    end

    if ( args.verbose )
        prgs.ClearProgress(true);
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
