function tiffWriter(im,prefix,imageData)

 if (exist('tifflib') ~= 3)
     tifflibLocation = which('/private/tifflib');
     if (isempty(tifflibLocation))
         error('tifflib does not exits on this machine!');
     end
     copyfile(tifflibLocation,'.');
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

sizes = size(im);
numDim = length(sizes);

if numDim<5
    frames= 1;
else
    frames = sizes(5);
end
if numDim<4
    channels = 1;
else
    channels = sizes(4);
end
if numDim<3
    stacks = 1;
else
    stacks = sizes(3);
end

w = whos('im');
tags.ImageLength = size(im,1);
tags.ImageWidth = size(im,2);
% tags.TileLength = size(im,1);
% tags.TileWidth = size(im,2);
tags.RowsPerStrip = size(im,2);
tags.Photometric = Tiff.Photometric.MinIsBlack;
tags.ExtraSamples = Tiff.ExtraSamples.Unspecified;
% if (channels==1)
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tags.SamplesPerPixel = 1;
% else
%     tags.PlanarConfiguration = Tiff.PlanarConfiguration.Separate;
%     tags.SamplesPerPixel = channels;
% end
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

fileName = sprintf('%s.tif',prefix);
tiffObj = Tiff(fileName,'w');
first = 1;
for t=1:frames
    for c=1:channels
        for z=1:stacks
            if ~first, tiffObj.writeDirectory(); end
            tiffObj.setTag(tags);
            tiffObj.write(squeeze(im(:,:,z,c,t)));
            if first, first = 0; end
        end
    end
end
tiffObj.close();
        
fprintf('Wrote %s.tif\n',prefix);

end

