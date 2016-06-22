% [pixelType,dataTypeLookup] = GetPixelTypeTIF(tifFile)

function [pixelType,imInfo] = GetPixelTypeTIF(tifFile)
    pixelType = [];
    
    dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double';
                  'logical'};

    dataTypeSize = [1;2;4;8;
                    1;2;4;8;
                    4;8;
                    1];

    dataTypeFormat = {'Unsigned integer';'Unsigned integer';'Unsigned integer';'Unsigned integer';
                        'Integer';'Integer';'Integer';'Integer';
                        'IEEE floating point';'IEEE floating point';
                        'Unsigned Integer'};
    
    imInfo = imfinfo(tifFile,'tif');
    sampleFormat = imInfo.SampleFormat;
    bitDepth = imInfo.BitDepth;
    
    bSizeMatch = (dataTypeSize == floor(bitDepth/8));
    bSampleMatch = strcmpi(sampleFormat,dataTypeFormat);
    
    formatIdx = find(bSizeMatch & bSampleMatch);
    if ( isempty(formatIdx) )
        return;
    end
    
    pixelType = dataTypeLookup{formatIdx};
end
