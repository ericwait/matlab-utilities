function colorIm = ColorImages(imIntensity, colors)
% COLORIMAGES Combines multi-channel intensity images into a single color image.
%
%   colorIm = ColorImages(imIntensity, colors) takes a multi-channel intensity image and 
%   applies specified colors to each channel to create a combined color image.
%
%   INPUTS:
%       imIntensity - A 3D matrix of intensity values with dimensions [height, width, channels].
%                     Each channel represents an intensity image to be colored.
%       colors      - A matrix of RGB color values of size [numChannels, 3]. Each row specifies
%                     the RGB color for the corresponding channel. RGB values should be in the
%                     range [0, 1].
%
%   OUTPUT:
%       colorIm     - A color image of size [height, width, 3], combining all channels with their
%                     respective colors. The image is converted to uint8 for display purposes.
%
%   NOTE:
%       - The number of channels in imIntensity must match the number of rows in colors.
%       - If imIntensity is logical, it is assumed to be a mask, and brightness adjustments are skipped.
%       - The function uses utility functions from the ImUtils package for type conversion and image
%         enhancement (BrightenImages and BrightenImagesGamma).

    % Check that imIntensity is a 3D array with up to 3 dimensions
    if ndims(imIntensity) > 3
        error('imIntensity must be a 3D matrix with dimensions [height, width, channels].');
    end
    
    % Get the number of channels from the colors input
    numChans = size(colors, 1);
    
    % Initialize the array to store colored images for each channel
    % Dimensions: [height, width, 3 (RGB), numChannels]
    imColors = zeros(size(imIntensity, 1), size(imIntensity, 2), 3, numChans, 'single');
    
    % Convert the intensity image to single precision
    im = ImUtils.ConvertType(imIntensity, 'single', true);
    
    % Prepare the color multipliers for each channel
    % Dimensions: [1, 1, 3 (RGB), numChannels]
    colorMultiplier = zeros(1, 1, 3, numChans, 'single');
    for c = 1:numChans
        colorMultiplier(1, 1, :, c) = colors(c, :);
    end
    
    % Process each channel
    for c = 1:numChans
        % Extract the current channel image
        im_temp = im(:, :, c);
        
        % Replicate the color multiplier to match the size of im_temp
        % color is of size [height, width, 3]
        color = repmat(colorMultiplier(1, 1, :, c), size(im_temp));
        
        % Multiply the intensity image with the color to get the colored image
        % Store the result in imColors (fourth dimension corresponds to channels)
        imColors(:, :, :, c) = repmat(im_temp, 1, 1, 3) .* color;

        % If imIntensity is logical (mask), skip brightness adjustments
        if islogical(imIntensity)
            continue
        end

        % Enhance the brightness of the current channel image
        im_temp = ImUtils.BrightenImages(im_temp, [], 0.0005, 20);
        % Apply gamma correction to the image
        im_temp = ImUtils.BrightenImagesGamma(im_temp, [], 0.95, 0.04);
        % Normalize the image to the range [0, 1]
        im_temp = mat2gray(im_temp);
        % Update the intensity image with the enhanced version
        im(:, :, c) = im_temp;
    end
            
    % Compute the maximum intensity across channels at each pixel
    imMax = max(im, [], 3);
    % Compute the sum of intensities across channels at each pixel
    imIntSum = sum(im, 3);
    % Avoid division by zero by setting zeros to ones
    imIntSum(imIntSum == 0) = 1;
    % Sum the colored images across channels
    imColrSum = sum(imColors, 4);
    % Normalize the summed colored image
    colorIm = imColrSum .* repmat(imMax ./ imIntSum, 1, 1, 3);
    % Convert the final image to uint8 for display purposes
    colorIm = im2uint8(colorIm);
end
