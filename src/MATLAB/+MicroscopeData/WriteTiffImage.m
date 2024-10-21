function WriteTiffImage(filePath, imageData)
    % Disable warnings for unknown TIFF tags
    s = warning('off', 'all');

    % Determine the size and type of the input imageData
    dataType = class(imageData);
    dims = ndims(imageData);

    % Validate dimensions
    if dims < 2 || dims > 4
        error('Expected imageData to be a 2D, 3D, or 4D array in XYZC format.');
    end

    % Handle different dimensions by padding with singletons if necessary
    switch dims
        case 2
            [sizeY, sizeX] = size(imageData);
            sizeZ = 1;
            numChannels = 1;
            imageData = reshape(imageData, [sizeY, sizeX, sizeZ, numChannels]);
        case 3
            [sizeY, sizeX, sizeZ] = size(imageData);
            numChannels = 1;
            imageData = reshape(imageData, [sizeY, sizeX, sizeZ, numChannels]);
        case 4
            [sizeY, sizeX, sizeZ, numChannels] = size(imageData);
    end

    % Create a Tiff object
    tiffObj = Tiff(filePath, 'w');

    % Write each slice (in Z) for each channel
    for z = 1:sizeZ
        for c = 1:numChannels
            setTiffTags(tiffObj, sizeX, sizeY, 1, dataType, z, sizeZ, c, numChannels);

            % Write the current slice for the current channel
            tiffObj.write(imageData(:, :, z, c));

            % Write a new directory if not at the last frame
            if z < sizeZ || c < numChannels
                tiffObj.writeDirectory();
            end
        end
    end

    % Close the Tiff object
    tiffObj.close();
    warning(s);
end

function setTiffTags(tiffObj, imageWidth, imageLength, samplesPerPixel, dataType, z, sizeZ, c, numChannels)
    % Photometric needs to be set before BitsPerSample
    tiffObj.setTag('Photometric', Tiff.Photometric.MinIsBlack);
    
    % These need to be set before SamplesPerPixel
    % Set data type specific tags
    switch dataType
        case 'uint8'
            tiffObj.setTag('BitsPerSample', 8);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.UInt);
        case 'uint16'
            tiffObj.setTag('BitsPerSample', 16);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.UInt);
        case 'uint32'
            tiffObj.setTag('BitsPerSample', 32);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.UInt);
        case 'int8'
            tiffObj.setTag('BitsPerSample', 8);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.Int);
        case 'int16'
            tiffObj.setTag('BitsPerSample', 16);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.Int);
        case 'int32'
            tiffObj.setTag('BitsPerSample', 32);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.Int);
        case 'single'
            tiffObj.setTag('BitsPerSample', 32);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.IEEEFP);
        case 'double'
            tiffObj.setTag('BitsPerSample', 64);
            tiffObj.setTag('SampleFormat', Tiff.SampleFormat.IEEEFP);
        otherwise
            error('Unsupported data type: %s', dataType);
    end

    % Set common TIFF tags
    tiffObj.setTag('ImageLength', imageLength);
    tiffObj.setTag('ImageWidth', imageWidth);
    
    tiffObj.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
    tiffObj.setTag('SamplesPerPixel', samplesPerPixel);
    tiffObj.setTag('Compression', Tiff.Compression.None);
    % Add ImageDescription tag for dimension metadata
    imageDescription = sprintf('ImageJ=1.52a\nchannels=%d\nslices=%d\nframes=1\nhyperstack=true\n', numChannels, sizeZ);
    tiffObj.setTag('ImageDescription', imageDescription);
end