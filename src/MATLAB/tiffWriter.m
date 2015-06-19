% TIFFWRITER(IM, PREFIX, IMAGEDATA, TIMELIST, CHANLIST, ZLIST, QUIET)
% TIMELIST, CHANLIST, and ZLIST are optional; pass in empty [] for the
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

function tiffWriter(im, outDir, imageData, timeList, chanList, zList, quiet)
if (exist('tifflib') ~= 3)
    tifflibLocation = which('/private/tifflib');
    if (isempty(tifflibLocation))
        error('tifflib does not exits on this machine!');
    end
    copyfile(tifflibLocation,'.');
end

if (~exist('quiet','var') || isempty(quiet))
    quiet = 0;
end

if (exist('imageData','var') && ~isempty(imageData) && isfield(imageData,'DatasetName'))
    idx = strfind(outDir,'"');
    outDir(idx) = [];
    idx = strfind(imageData.DatasetName,'"');
    imageData.DatasetName(idx) = [];
    createMetadata(outDir,imageData,quiet);
else
    if isstruct(imageData)
        error('ImageData struct is malformed!');
    end
    dName = imageData;
    imageData = [];
    imageData.DatasetName = dName;
    
    imageData.YDimension = size(im,1);
    imageData.XDimension = size(im,2);
    imageData.ZDimension = size(im,3);
    imageData.NumberOfChannels = size(im,4);
    imageData.NumberOfFrames = size(im,5);
    
    imageData.XPixelPhysicalSize = 1.0;
    imageData.YPixelPhysicalSize = 1.0;
    imageData.ZPixelPhysicalSize = 1.0;
    
    createMetadata(outDir,imageData);
    outDir = fullfile(outDir,imageData.DatasetName);
end

if (~exist('timeList','var') || isempty(timeList))
    timeList = 1:imageData.NumberOfFrames;
else
    if (max(timeList(:))>imageData.NumberOfFrames)
        error('A value in timeList is greater than the number of frames in the image data!');
    end
end
if (size(im,5)~=length(timeList))
    error('There are %d frames and %d frames to be written!',size(im,5),length(timeList));
end

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

if (~exist('zList','var') || isempty(zList))
    zList = 1:imageData.ZDimension;
else
    if (max(zList(:))>imageData.ZDimension)
        error('A value in zList is greater than the z dimension in the image data!');
    end
end
if (size(im,3)~=length(zList))
    error('There are %d z images and %d z images to be written!',size(im,3),length(zList));
end

w = whos('im');
tags.ImageLength = size(im,1);
tags.ImageWidth = size(im,2);
tags.RowsPerStrip = size(im,2);
tags.Photometric = Tiff.Photometric.MinIsBlack;
tags.ExtraSamples = Tiff.ExtraSamples.Unspecified;
tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tags.SamplesPerPixel = 1;
tags.Compression = Tiff.Compression.LZW;
tags.Software = 'MATLAB';

switch w.class
    case 'uint8'
        tags.SampleFormat = Tiff.SampleFormat.UInt;
        tags.BitsPerSample = 8;
    case 'uint16'
        tags.SampleFormat = Tiff.SampleFormat.UInt;
        tags.BitsPerSample = 16;
    case 'uint32'
        tags.SampleFormat = Tiff.SampleFormat.UInt;
        tags.BitsPerSample = 32;
    case 'int8'
        tags.SampleFormat = Tiff.SampleFormat.Int;
        tags.BitsPerSample = 8;
    case 'int16'
        tags.SampleFormat = Tiff.SampleFormat.Int;
        tags.BitsPerSample = 16;
    case 'int32'
        tags.SampleFormat = Tiff.SampleFormat.Int;
        tags.BitsPerSample = 32;
    case 'single'
        tags.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tags.BitsPerSample = 32;
    case 'double'
        tags.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tags.BitsPerSample = 64;
    case 'logical'
        imtemp = zeros(size(im),'uint8');
        imtemp(im) = 255;
        im = imtemp;
        clear imtemp
        tags.SampleFormat = Tiff.SampleFormat.UInt;
        tags.BitsPerSample = 8;
    otherwise
        error('Image type unsupported!');
end

if (~quiet)
    iter = length(timeList)*length(chanList)*length(zList);
    PrintProgress(iter,true);
    i=1;
end

tic
for t=1:length(timeList)
    for c=1:length(chanList)
        for z=1:length(zList)
            tiffObj = Tiff(fullfile(outDir,[imageData.DatasetName,sprintf('_c%02d_t%04d_z%04d.tif',chanList(c),timeList(t),zList(z))]),'w');
            tiffObj.setTag(tags);
            tiffObj.write(im(:,:,z,c,t),tags);
            tiffObj.close();
            
            if (~quiet)
                PrintProgress(i);
                i = i+1;
            end
            
        end
    end
end

if (~quiet)
    PrintProgress(0,false);
end

if (~quiet)
    fprintf('Wrote %.0fMB in %s\n',...
        ((tags.BitsPerSample/8)*imageData.XDimension*imageData.YDimension*imageData.ZDimension*imageData.NumberOfChannels*imageData.NumberOfFrames)/(1024*1024),...
        printTime(toc));
end
end

