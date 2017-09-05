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
% imVersion - open the version of the image (e.g. Original, MIP, Processed)
%       Default is 'Original'
% getMIP - return only a 2D image.  A precomputed Maximum Intensity
%       Projection (MIP) will be returned if the orignal was 3D
% verbose - Display verbose output and timing information
% prompt - False to completely disable prompts, true to force prompt, leave unspecified or empty for default prompt behavior
% promptTitle - Open dialog title in the case that prompting is required

function [im, imD] = Reader(varargin)
    readerTic = tic;
    im = [];

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
    klbFiles = dir(fullfile(imPath,[imD.DatasetName '*.klb']));
    if ( ~isempty(klbFiles))
        [im,imD] = MicroscopeData.ReaderKLB('imageData',imD, 'chanList',args.chanList, 'timeRange',args.timeRange, 'roi_xyz',args.roi_xyz, 'getMIP',args.getMIP,...
            'outType',args.outType, 'normalize',args.normalize, 'imVersion',args.imVersion, 'verbose',args.verbose, 'prompt',false);
    else
        hdf5File = fullfile(imPath,[imD.DatasetName '.h5']);
        if ( exist(hdf5File,'file') )
            [im,imD] = MicroscopeData.ReaderH5('imageData',imD, 'chanList',args.chanList, 'timeRange',args.timeRange, 'roi_xyz',args.roi_xyz, 'getMIP',args.getMIP,...
                'outType',args.outType, 'normalize',args.normalize, 'imVersion',args.imVersion, 'verbose',args.verbose, 'prompt',false);
        else

            tifFile = fullfile(imPath,sprintf('%s_c%02d_t%04d_z%04d.tif',imD.DatasetName,1,1,1));
            if ( exist(tifFile,'file'))
                [im,imD] = MicroscopeData.ReaderTIF('imageData',imD, 'chanList',args.chanList, 'timeRange',args.timeRange, 'roi_xyz',args.roi_xyz,...
                    'outType',args.outType, 'normalize',args.normalize, 'verbose',args.verbose, 'prompt',false);

                if (args.getMIP && size(im,3)>1)
                    imMIP = zeros(size(im,1),size(im,2),1,size(im,4),size(im,5),'like',im);
                    for t=1:imD.NumberOfFrames
                        for c=1:imD.NumberOfChannels
                            imMIP(:,:,1,c,t) = max(im(:,:,:,c,t),[],3);
                        end
                    end
                    im = imMIP;
                end
            end
        end
    end

    if (isempty(im))
       warning('No supported image type found!');
    end
    
end
