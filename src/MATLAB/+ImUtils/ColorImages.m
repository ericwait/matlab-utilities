function colorIm = ColorImages(imIntensity, colors)
% COLORIMAGES Generates a color image from multi-channel intensity images and a set of colors.
%
%   colorIm = ColorImages(imIntensity, colors) takes a multi-channel intensity image and 
%   applies a set of colors to each channel to create a color image.
%
%   INPUTS:
%       imIntensity - A 5D matrix of intensity values of size [height, width, depth, channels, frames].
%       colors - A matrix of RGB color values of size [numChannels, 3]. Each row specifies the
%                RGB color for the corresponding channel.
%
%   OUTPUTS:
%       colorIm - A 5D matrix of color images of size [height, width, 3, frames, depth].
%                 The resulting image is converted to uint8 for display purposes.
%
%   EXAMPLE USAGE:
%       imIntensity = rand(256, 256, 1, 3, 10);  % Example intensity image
%       colors = [1 0 0; 0 1 0; 0 0 1];         % Colors for each channel (RGB)
%       colorIm = ColorImages(imIntensity, colors);
%
%   NOTE:
%       - The number of channels in imIntensity must match the number of rows in colors.
%       - If the depth dimension is not singleton, it will be moved to the sixth dimension.

    % Extract dimensions
    numZ = size(imIntensity, 3);
    numChans = size(imIntensity, 4);
    numColors = size(colors, 1);

    % Ensure the number of colors matches the number of channels
    if numChans ~= numColors
        error('The number of colors need to match the number of channels (fourth dimension) of the image.');
    end

    % Move the third dimension to the sixth if it is not singleton
    if numZ ~= 1
        imIntensity = permute(imIntensity, [1, 2, 6, 4, 5, 3]);
    end
    
    % Normalize and convert intensity image to single precision
    im = ImUtils.ConvertType(imIntensity, 'single', true);
    
    % Reshape and permute colors for broadcasting
    colors = reshape(colors, 1, 1, 3, numChans);
    
    % Apply colors to each channel using implicit expansion
    imColors = bsxfun(@times, im, colors);

    % Sum colorized images across channels
    imColrSum = sum(imColors, 4);
    
    % Avoid division by zero
    imSum = sum(im, 4);
    imSum(imSum == 0) = 1;  % Prevent division by zero
    
    % Compute maximum intensity across channels
    imMax = max(im, [], 4);
    
    % Normalization
    imNormalizer = imMax ./ imSum;
    colorIm = imColrSum .* imNormalizer;

    % Convert back to uint8 for display
    colorIm = im2uint8(colorIm);
end
