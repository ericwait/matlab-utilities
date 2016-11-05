% [IM, IMAGEDATA] = MicroscopeData.Sandbox.ReaderH5([path], varargin)
%
% Optional Parameters (Key,Value pairs):
%
% imageData - Input metadata, if specified, the optional path argument is ignored
% chanList - List of channels to read
% timeRange - Range min and max times to read
% roi_xyz - x,y,z min and max roi to read
% outType - Desired output type, conversion is applied if different from image
% normalize - Normalize images on [0,1] per frame before conersion to output type
% imVersion - open the version of the image (e.g. Original, MIP, Processed)
%       Default is 'Original'
% verbose - Display verbose output and timing information
% prompt - False to completely disable prompts, true to force prompt, leave unspecified or empty for default prompt behavior
% promptTitle - Open dialog title in the case that prompting is required

function [im, imD] = ReaderH5(varargin)
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

    if (~exist(fullfile(imPath,[imD.DatasetName '.h5']),'file'))
        warning('No image to read!');
        return
    end

    info = h5info(fullfile(imPath,[imD.DatasetName '.h5']));
    imGrpInfo = info.Groups;
    if (isempty(imGrpInfo) || ~strcmp(imGrpInfo.Name,'/Images'))
        error('File structure malformed!');
    end

    hasMIP = false;
    if (any(strcmpi([args.imVersion,'_MIP'],{imGrpInfo.Datasets.Name})))
        hasMIP = true;
    end
    if (~any(strcmp(args.imVersion,{imGrpInfo.Datasets.Name})))
        warning('No images with at this data field!');
        return
    end

    inType = class(h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion],[1 1 1 1 1],[1 1 1 1 1]));
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

    %build up the imSize by the input arguments
    imSize = ones(1,5);
    imSize(1:3) = 1 + diff(Utils.SwapXY_RC(args.roi_xyz),1); % get the extent of the roi
    imSize(4) = length(args.chanList); % set the number of channeles desired
    imSize(5) = args.timeRange(2) - args.timeRange(1) + 1; % set the number of frames from the frame range
    if (args.getMIP)
        imSize(3) = 1;
    end

    if ( args.verbose )
        orgSize = [imD.Dimensions(1),imD.Dimensions(2),imD.Dimensions(3),imD.NumberOfChannels,imD.NumberOfFrames];
        fprintf('Reading %s (%d,%d,%d,%d,%d) %s %5.2fMB --> Into (%d,%d,%d,%d,%d) %s %5.2fMB,',...
            args.imVersion,...
            orgSize(2),orgSize(1),orgSize(3),orgSize(4),orgSize(5),inType,...
            (prod(orgSize)*inBytes)/(1024*1024),...
            imSize(1),imSize(2),imSize(3),imSize(4),imSize(5),args.outType,...
            (prod(imSize)*outBytes)/(1024*1024));

        if (convert)
            prgs = Utils.CmdlnProgress(length(args.chanList)*imSize(5),true);
        else
            prgs = Utils.CmdlnProgress(length(args.chanList),true);
        end
        drawnow
    end

    if (~strcmpi(args.outType,'logical'))
        im = zeros(imSize, args.outType);
    else
        im = false(imSize);
    end

    tic
    if ( convert )
        for c=1:length(args.chanList)
            for t=1:imSize(5)
                if (args.getMIP)
                    if (hasMIP)
                        tempIm = h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion,'_MIP'], [Utils.SwapXY_RC(args.roi_xyz(1,1:2)) 1 args.chanList(c) t+args.timeRange(1)-1], [imSize(1:2) 1 1 1]);
                    else
                        tempIm = h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion], [Utils.SwapXY_RC(args.roi_xyz(1,:)) args.chanList(c) t+args.timeRange(1)-1], [imSize(1:3) 1 1]);
                        tempIm = max(tempIm,[],3);
                    end
                else
                    tempIm = h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion], [Utils.SwapXY_RC(args.roi_xyz(1,:)) args.chanList(c) t+args.timeRange(1)-1], [imSize(1:3) 1 1]);
                end
                im(:,:,:,c,t) = ImUtils.ConvertType(tempIm,args.outType,args.normalize);
                if(args.verbose)
                    prgs.PrintProgress(t+(c-1)*imSize(5));
                end
            end
        end

        clear tempIm;
    else
        for c=1:length(args.chanList)
            if (args.getMIP)
                if (hasMIP)
                    im(:,:,:,c,:) = h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion,'_MIP'], [Utils.SwapXY_RC(args.roi_xyz(1,1:2)) 1 args.chanList(c) args.timeRange(1)], [imSize(1:2) 1 1 imSize(5)]);
                else
                    tempIm = h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion], [Utils.SwapXY_RC(args.roi_xyz(1,:)) args.chanList(c) args.timeRange(1)], [imSize(1:3) 1 imSize(5)]);
                    im(:,:,:,c,:) = max(tempIm,[],3);
                end
            else
                im(:,:,:,c,:) = h5read(fullfile(imPath,[imD.DatasetName '.h5']),['/Images/',args.imVersion], [Utils.SwapXY_RC(args.roi_xyz(1,:)) args.chanList(c) args.timeRange(1)], [imSize(1:3) 1 imSize(5)]);
            end
            if(args.verbose)
                prgs.PrintProgress(c);
            end
        end
    end
    if (args.verbose)
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
