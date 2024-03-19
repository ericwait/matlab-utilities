function colorIm = ColorImages(imIntensity, colors)
   
    numZ = size(imIntensity, 3);
    numChans = size(imIntensity, 4);
    numFrames = size(imIntensity, 5);
    numColors = size(colors, 1);

    if numChans ~= numColors
        error('The number of colors need to match the number of channels (forth dimension) of the image.')
    end

    % Check to see if the third dimension is singleton.
    % If not, move it to the 6th.

    if numZ ~=1
        imIntensity = permute(imIntensity, [1, 2, 6, 4, 5, 3]);
    end
    
    colorsPerm = permute(colors, [3,4,2,1]);
    colorMultiplier = repmat(colorsPerm, [size(imIntensity, 1:2), 1, 1, numFrames, numZ]);

    im = ImUtils.ConvertType(imIntensity, 'single', true);  % normalize and convert to single precision
    im = repmat(im, [1, 1, 3, 1, 1, 1]);
    imColors = im .* colorMultiplier;
    
    % Combine colorized images into a single image
    imMax = max(im, [], 4);
    imIntSum = sum(im, 4);
    imIntSum(imIntSum == 0) = 1;  % Avoid division by zero
    imColrSum = sum(imColors, 4);
    
    % Final image calculation
    imNormalizer = imMax ./ imIntSum;
    colorIm = imColrSum .* imNormalizer;
    colorIm = im2uint8(colorIm);  % Convert back to uint8 for display
end
