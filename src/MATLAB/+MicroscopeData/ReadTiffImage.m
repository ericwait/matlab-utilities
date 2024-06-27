function outputImage = ReadTiffImage(filePath)
    s = warning('off', 'all'); % To ignore unknown TIFF tag.

    % Initialize Tiff object
    tiffObj = Tiff(filePath, 'r');
    numFrames = 1;
    
    % Count the number of frames
    while ~tiffObj.lastDirectory()
        numFrames = numFrames + 1;
        tiffObj.nextDirectory();
    end

    % Initialize variables
    tiffObj.setDirectory(1);
    [imageWidth, imageLength, samplesPerPixel, sampleFormat, bitsPerSample] = getTiffTags(tiffObj);
    
    % Preallocate the output image array based on the image properties
    dataType = getDataType(sampleFormat, bitsPerSample);
    if samplesPerPixel == 1
        outputImage = zeros(imageLength, imageWidth, numFrames, dataType); % grayscale
    else
        outputImage = zeros(imageLength, imageWidth, samplesPerPixel, numFrames, dataType); % color
    end
    
    % Read each frame and store it in the output image array
    for frameIdx = 1:numFrames
        tiffObj.setDirectory(frameIdx);
        if samplesPerPixel == 1
            outputImage(:, :, frameIdx) = tiffObj.read();
        else
            outputImage(:, :, :, frameIdx) = tiffObj.read();
        end
    end

    % Close the Tiff object
    tiffObj.close();
    warning(s);
end

function [imageWidth, imageLength, samplesPerPixel, sampleFormat, bitsPerSample] = getTiffTags(tiffObj)
    imageWidth = tiffObj.getTag('ImageWidth');
    imageLength = tiffObj.getTag('ImageLength');
    samplesPerPixel = tiffObj.getTag('SamplesPerPixel');
    sampleFormat = tiffObj.getTag('SampleFormat');
    bitsPerSample = tiffObj.getTag('BitsPerSample');
end

function dataType = getDataType(sampleFormat, bitsPerSample)
    switch sampleFormat
        case 1 % Unsigned integer data
            dataType = getUnsignedDataType(bitsPerSample);
        case 2 % Signed integer data
            dataType = getSignedDataType(bitsPerSample);
        case 3 % Floating point data
            dataType = getFloatDataType(bitsPerSample);
    end
end

function dataType = getUnsignedDataType(bitsPerSample)
    switch bitsPerSample
        case 8
            dataType = 'uint8';
        case 16
            dataType = 'uint16';
        case 32
            dataType = 'uint32';
    end
end

function dataType = getSignedDataType(bitsPerSample)
    switch bitsPerSample
        case 8
            dataType = 'int8';
        case 16
            dataType = 'int16';
        case 32
            dataType = 'int32';
    end
end

function dataType = getFloatDataType(bitsPerSample)
    switch bitsPerSample
        case 32
            dataType = 'single';
        case 64
            dataType = 'double';
    end
end