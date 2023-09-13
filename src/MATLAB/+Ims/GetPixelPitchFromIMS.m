function pixelPitch = GetPixelPitchFromIMS(filePath)
    % This function reads the pixel pitch (x, y, z dimensions) from the metadata of an IMS file.
    % 
    % Inputs:
    %   filePath - the full path to the IMS file
    %
    % Outputs:
    %   pixelPitch - a vector [xPitch, yPitch, zPitch] containing the pixel sizes in x, y, and z dimensions
    
    % Define the path to the metadata attributes
    metadataPath = '/DataSetInfo/Image';
    
    try
        % Read extents and number of pixels in each dimension from metadata
        extMin0 = stringArray2Double(h5readatt(filePath, metadataPath, 'ExtMin0'));
        extMax0 = stringArray2Double(h5readatt(filePath, metadataPath, 'ExtMax0'));
        extMin1 = stringArray2Double(h5readatt(filePath, metadataPath, 'ExtMin1'));
        extMax1 = stringArray2Double(h5readatt(filePath, metadataPath, 'ExtMax1'));
        extMin2 = stringArray2Double(h5readatt(filePath, metadataPath, 'ExtMin2'));
        extMax2 = stringArray2Double(h5readatt(filePath, metadataPath, 'ExtMax2'));
        
        xPixels = stringArray2Double(h5readatt(filePath, metadataPath, 'X'));
        yPixels = stringArray2Double(h5readatt(filePath, metadataPath, 'Y'));
        zPixels = stringArray2Double(h5readatt(filePath, metadataPath, 'Z'));
        
        % Compute pixel pitch in each dimension
        xPitch = (extMax0 - extMin0) / xPixels;
        yPitch = (extMax1 - extMin1) / yPixels;
        zPitch = (extMax2 - extMin2) / zPixels;
        
        % Combine into a single vector
        pixelPitch = [xPitch, yPitch, zPitch];
        
    catch ME
        warning('Could not read pixel pitch from IMS file. Returning empty array.');
        fprintf(ME.message);
        pixelPitch = [];
        H5F.close(filePath);
    end
end

function num = stringArray2Double(strArray)
    charArray = '';
    for i = 1:numel(strArray)
        charArray = [charArray, char(strArray(i))];
    end
    num = str2double(charArray);
end
