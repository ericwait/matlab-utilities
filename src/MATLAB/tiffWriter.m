% TIFFREADER(IM, PREFIX, IMAGEDATA, TIMELIST, CHANLIST, ZLIST)
% TIMELIST, CHANLIST, and ZLIST are optional; pass in empty [] for the 
% arguments that come prior to the one you would like to populate.
%
% IM = the image data to write. Assumes a 5-D image in the format
% (X,Y,Z,channel,time). If the image already exists and TIMELIST, CHANLIST,
% and ZLIST are populated with less then the whole image, the existing
% image is updated.  If the file does not exist and the image data doesn't
% fill the whole image, the rest will be filled in with black (zeros)
% frames.

% PREFIX = filepath in the format ('c:\path\FilePrefix')
% IMAGEDATA = metadata that will be written to accompany the image
% TIMELIST = a list of frames that the fifth dimention represents
% CHANLIST = the channels that the input image represents
% ZLIST = the z slices that the input image represents

function tiffWriter(im, prefix, imageData, timeList, chanList, zList)

if (exist('tifflib') ~= 3)
    tifflibLocation = which('/private/tifflib');
    if (isempty(tifflibLocation))
        error('tifflib does not exits on this machine!');
    end
    copyfile(tifflibLocation,'.');
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

idx = strfind(prefix,'"');
prefix(idx) = [];
idx = strfind(imageData.DatasetName,'"');
imageData.DatasetName(idx) = [];
if (exist('imageData','var') && ~isempty(imageData))
    idx = strfind(prefix,'\');
    if (isempty(idx))
        idx = length(prefix);
    end
    createMetadata(prefix(1:idx(end)),imageData);
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
    otherwise
        error('Image type unsupported!');
end
tic
for t=1:length(timeList)
    for c=1:length(chanList)
        for z=1:length(zList)
            tiffObj = Tiff([prefix,sprintf('_c%02d_t%04d_z%04d.tif',chanList(c),timeList(t),zList(z))],'w');
            tiffObj.setTag(tags);
            tiffObj.write(im(:,:,zList(z),chanList(c),timeList(t)),tags);
            tiffObj.close();
        end
    end
end

fprintf('Wrote %.0fMB in %s\n',...
    ((tags.BitsPerSample/8)*imageData.XDimension*imageData.YDimension*imageData.ZDimension*imageData.NumberOfChannels*imageData.NumberOfFrames)/(1024*1024),...
    printTime(toc));

end

