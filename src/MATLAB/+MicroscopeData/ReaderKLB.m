% [IM, IMAGEDATA] = MicroscopeData.ReaderKLB([path], varargin)
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

function [im, imD] = ReaderKLB(varargin)
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
        loadPath = fullfile(args.imageData.imageDir,[args.imageData.DatasetName,'.json']);
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
    elseif (args.timeRange(2)>imD.NumberOfFrames)
        error('Requesting frame beyond the size of the dataset!');
    end

    if (isempty(args.roi_xyz))
        args.roi_xyz = [1 1 1; imD.Dimensions];
    else
        args.roi_xyz(2,:) = min(args.roi_xyz(2,:),imD.Dimensions);
    end

    klbList = dir(fullfile(imPath,[imD.DatasetName '*.klb']));
    if (isempty(klbList))
        warning('No image to read!');
        return
    end

    try
        inType = class(MicroscopeData.KLB.readKLBroi(fullfile(imPath,klbList(1).name),ones(2,5)));
    catch err
        warning(sprintf('%s\nNo images with at this data field!',err.message));
        return
    end
    
    inIdx = find(strcmp(inType,dataTypeLookup));
    if ( ~isempty(inIdx) )
        inBytes = dataTypeSize(inIdx);
    else
        error('Unsupported image type!');
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
    
    if (~isfield(imD,'PixelFormat'))
        imD.PixelFormat = args.outType;
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

    prgs = Utils.CmdlnProgress(length(args.chanList)*length(args.timeRange(1):args.timeRange(2)),true);
    
    if ( args.verbose )
        orgSize = [imD.Dimensions(1),imD.Dimensions(2),imD.Dimensions(3),imD.NumberOfChannels,imD.NumberOfFrames];
        fprintf('Reading %s (%d,%d,%d,%d,%d) %s %5.2fMB --> Into (%d,%d,%d,%d,%d) %s %5.2fMB,',...
            imD.DatasetName,...
            orgSize(2),orgSize(1),orgSize(3),orgSize(4),orgSize(5),inType,...
            (prod(orgSize)*inBytes)/(1024*1024),...
            imSize(1),imSize(2),imSize(3),imSize(4),imSize(5),args.outType,...
            (prod(imSize)*outBytes)/(1024*1024));

        drawnow
    end
    
    filePerC = ~isempty(regexp(klbList(1).name,'_c\d'));
    filePerT = ~isempty(regexp(klbList(1).name,'_t\d+'));
    prgsIn = [];
    if (args.verbose)
        prgsIn = prgs;
    end
    
    roi_xyz = args.roi_xyz;
    roi_xyz(:,4) = [args.chanList(1);args.chanList(end)];
    roi_xyz(:,5) = args.timeRange';
    im = readKLBChunk(imD,args.outType,roi_xyz,args.chanList,filePerC,filePerT,args.outType,args.normalize,prgsIn,args.getMIP);

    if (args.verbose)
        prgs.ClearProgress(true);
    end

    imSize = size(im);
    imD.Dimensions = Utils.SwapXY_RC(imSize(1:3));
    if (ndims(im)>3)
        imD.NumberOfChannels = size(im,4);
    else
        imD.NumberOfChannels = 1;
    end
    if (ndims(im)>4)
        imD.NumberOfFrames = size(im,5);
    else
        imD.NumberOfFrames = 1;
    end

    if (isfield(imD,'ChannelNames') && ~isempty(imD.ChannelNames))
        if(length(imD.ChannelNames)>length(args.chanList))
            imD.ChannelNames = imD.ChannelNames(args.chanList)';
        end
    else
        imD.ChannelNames = {};
    end
    if (isfield(imD,'ChannelColors') && ~isempty(imD.ChannelColors))
        if (size(imD.ChannelColors,1)>length(args.chanList))
            imD.ChannelColors = imD.ChannelColors(args.chanList,:);
        end
    else
        imD.ChannelColors = [];
    end
end

function im = readKLBChunk(imD,outType,roi_xyz,chanList,filePerC,filePerT,cnvrtType,normalize,prgs,getMIP)
    if (getMIP)
        mipROI = roi_xyz(2,:)-roi_xyz(1,:)+1;
        mipROI(3) = 1;
        im = zeros(Utils.SwapXY_RC(mipROI),outType);
    else
        im = zeros(Utils.SwapXY_RC(roi_xyz(2,:)-roi_xyz(1,:))+1,outType);
    end
    
    myCluster = parcluster('local');
    threads = myCluster.NumWorkers;
    
    if (filePerC)
        if (filePerT)
            % individual image per c and t
            i = 0;
            for t=1:length(roi_xyz(1,5):roi_xyz(2,5))
                for c=1:length(chanList)
                    fileName = sprintf('%s_c%d_t%04d.klb',imD.DatasetName,chanList(c),t+roi_xyz(1,5)-1);
                    imTemp = MicroscopeData.KLB.readKLBroi(fullfile(imD.imageDir,fileName), Utils.SwapXY_RC([[roi_xyz(1,[2,1,3]),1,1]; [roi_xyz(2,[2,1,3]),1,1]]),threads);
                    if (getMIP)
                        imTemp = max(imTemp,[],3);
                    end
                    [im,prgs] = placeIm(imTemp,c,t,cnvrtType,normalize,im,prgs);
                    i = i +1;
                    if (~isempty(prgs))
                        prgs.PrintProgress(i);
                    end
                end
            end
        else
            % only split by c
            i=0;
            t = 1:length(roi_xyz(1,5):roi_xyz(2,5));
            for c=1:length(chanList)
                fileName = sprintf('%s_c%d.klb',imD.DatasetName,chanList(c));
                imTemp = MicroscopeData.KLB.readKLBroi(fullfile(imD.imageDir,fileName), Utils.SwapXY_RC([[roi_xyz(1,1:3),1,roi_xyz(1,5)]; [roi_xyz(2,1:3),1,roi_xyz(2,5)]]),threads);
                if (getMIP)
                    imTemp = max(imTemp,[],3);
                end
                [im,prgs] = placeIm(imTemp,c,t,cnvrtType,normalize,im,prgs);
                i = i +1;
                if (~isempty(prgs))
                    prgs.PrintProgress(i*length(roi_xyz(1,5):roi_xyz(2,5)));
                end
            end
        end
    elseif (filePerT)
        % only split by t
        i = 0;
        c=1:length(chanList);
        for t=1:length(roi_xyz(1,5):roi_xyz(2,5))
            fileName = sprintf('%s_t%04d.klb',imD.DatasetName,t+roi_xyz(1,5)-1);
            imTemp = MicroscopeData.KLB.readKLBroi(fullfile(imD.imageDir,fileName), Utils.SwapXY_RC([[roi_xyz(1,1:4),1]; [roi_xyz(2,1:4),1]]),threads);
            if (getMIP)
                imTemp = max(imTemp,[],3);
            end
            [im,prgs] = placeIm(imTemp,c,t,cnvrtType,normalize,im,prgs);
            i = i +1;
            if (~isempty(prgs))
                prgs.PrintProgress(i*length(roi_xyz(1,4):roi_xyz(2,4)));
            end
        end
    else
        % only one file
        m = memory;
        iMem = MicroscopeData.GetImageSetSizeInBytes(imD,imD.PixelFormat);
        if (getMIP && iMem>m.MemAvailableAllArrays)
            for t=roi_xyz(1,5):roi_xyz(2,5)
                for c=roi_xyz(1,4):roi_xyz(2,4)
                    imTemp = MicroscopeData.KLB.readKLBroi(fullfile(imD.imageDir,[imD.DatasetName '.klb']), Utils.SwapXY_RC([[roi_xyz(1,1:3),c,t]; [roi_xyz(2,1:3),c,t]]),threads);
                    imTemp = max(imTemp,[],3);
                    [im,prgs] = placeIm(imTemp,c,t,cnvrtType,normalize,im,prgs);
                end
            end
        else
            imTemp = ImUtils.ConvertType(MicroscopeData.KLB.readKLBroi(fullfile(imD.imageDir,[imD.DatasetName '.klb']),Utils.SwapXY_RC(roi_xyz),threads),cnvrtType,normalize);
            if (getMIP)
                imTemp = max(imTemp,[],3);
            end
            [im,prgs] = placeIm(imTemp,1:length(chanList),1:length(roi_xyz(1,5):roi_xyz(2,5)),cnvrtType,normalize,im,prgs);
        end
        if (~isempty(prgs))
            prgs.PrintProgress(length(roi_xyz(1,5):roi_xyz(2,5))*length(roi_xyz(1,4):roi_xyz(2,4)));
        end
    end
end

function [im,prgs] = placeIm(imTemp,c,t,cnvrtType,normalize,im,prgs)
    imTemp = permute(imTemp,[2,1,3,4,5]);
    try
        im(:,:,:,c,t) = ImUtils.ConvertType(imTemp,cnvrtType,normalize);
    catch err
        imTemp = permute(imTemp,[2,1,3,4,5]);
        im(:,:,:,c,t) = ImUtils.ConvertType(imTemp,cnvrtType,normalize);
        warning(sprintf('Image is saved with row major access. Consider resaving as column major.\n%s',err.message));
        if (~isempty(prgs))
            prgs.StopUsingBackspaces();
        end
    end
end