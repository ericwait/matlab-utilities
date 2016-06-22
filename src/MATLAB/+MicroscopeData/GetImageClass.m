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
    [imClass,imInfo] = MicroscopeData.Helper.GetPixelTypeTIF(fullfile(imageData.imageDir,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)));
end
end
