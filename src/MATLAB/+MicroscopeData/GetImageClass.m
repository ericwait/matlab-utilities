function [ imClass, imInfo ] = GetImageClass( imageData )
%GETIMAGETYPE Summary of this function goes here
%   Detailed explanation goes here

if (isfield(imageData,'PixelFormat'))
    imClass = imageData.PixelFormat;
    imInfo.BitDepth = 8;
    switch imClass
        case 'uint16'
            imInfo.BitDepth = 16;
        case 'int16'
            imInfo.BitDepth = 16;
        case 'single'
            imInfo.BitDepth = 32;
        case 'uint32'
            imInfo.BitDepth = 32;
        case 'int32'
            imInfo.BitDepth = 32;
        case 'double'
            imInfo.BitDepth = 64;
    end
else
    imInfo = imfinfo(fullfile(imageData.imageDir,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'tif');
    if (imInfo(1).BitDepth==8)
        imClass = 'uint8';
    elseif (imInfo(1).BitDepth==16)
        imClass = 'uint16';
    elseif (imInfo(1).BitDepth==32)
        imClass = 'uint32';
    else
        imClass = 'double';
    end
end
end
