% WriterKLB(im, outDir, imageData, chanList, quiet)
% CHANLIST is optional; pass in empty [] for the
% arguments that come prior to the one you would like to populate.
%
% IM = the image data to write. Assumes a 5-D image in the format
% (X,Y,Z,channel,time). If the image already exists and TIMELIST, CHANLIST,
% and ZLIST are populated with less then the whole image, the existing
% image is updated.  If the file does not exist and the image data doesn't
% fill the whole image, the rest will be filled in with black (zeros)
% frames.
%
% PREFIX = filepath in the format ('c:\path\FilePrefix') unless there is no
% imagedata in which case it should be ('c:\path)
% IMAGEDATA = metadata that will be written to accompany the image.  If you
% want this generated from the image data only, this paramater should be
% just a string representing the dataset name.  See PREFIX above in such
% case.
% TIMELIST = a list of frames that the fifth dimention represents
% CHANLIST = the channels that the input image represents
% ZLIST = the z slices that the input image represents
% QUITE = suppress printing out progress

function WriterKLB(im, outDir, imageData, chanList, quiet)
if (~exist('quiet','var') || isempty(quiet))
    quiet = 0;
end

if (exist('imageData','var') && ~isempty(imageData) && isfield(imageData,'DatasetName'))
    idx = strfind(imageData.DatasetName,'"');
    imageData.DatasetName(idx) = [];
else
    if isstruct(imageData)
        error('ImageData struct is malformed!');
    end
    dName = imageData;
    imageData = [];
    imageData.DatasetName = dName;

    imageData.Dimensions = Utils.SwapXY_RC(size(im))';
    imageData.NumberOfChannels = size(im,4);
    imageData.NumberOfFrames = size(im,5);

    imageData.PixelPhysicalSizes = [1.0; 1.0; 1.0]; 
end

dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double'};

dataTypeSize = [1;2;4;8;
                1;2;4;8;
                4;8];

w = whos('im');
typeIdx = find(strcmp(w.class,dataTypeLookup));
if ( ~isempty(typeIdx) )
    bytes = dataTypeSize(typeIdx);
end

if (~isfield(imageData,'PixelFormat'))
    imageData.PixelFormat = w.class;
end

if (exist('outDir','var') && ~isempty(outDir))
    idx = strfind(outDir,'"');
    outDir(idx) = [];
elseif (isfield(imageData,'imageDir') && ~isempty(imageData.imageDir))
    outDir = imageData.imageDir;
else
    outDir = fullfile('.',imageData.DatasetName);
end

MicroscopeData.CreateMetadata(outDir,imageData, 'verbose',~quiet);

if (~exist('chanList','var') || isempty(chanList))
    chanList = 1:imageData.NumberOfChannels;
else
    if (max(chanList(:))>imageData.NumberOfChannels)
        error('A value in chanList is greater than the number of channels in the image data!');
    end
end
if (size(im,4)~=length(chanList))
    error('There are %d channels and %d channels to be written!',size(im,4),length(chanList));
end

tic
for c=1:length(chanList)
    fname = fullfile(outDir,[imageData.DatasetName,sprintf('_c%02d.klb',chanList(c))]);
    MicroscopeData.Sandbox.KLB.writeKLBstack(im(:,:,:,c,:), fname, [],[],[],2);
end

if (~quiet)
    fprintf('Wrote %.0fMB in %s\n',...
        (bytes*prod(imageData.Dimensions)*imageData.NumberOfChannels*imageData.NumberOfFrames)/(1024*1024),...
        Utils.PrintTime(toc));
end
end

