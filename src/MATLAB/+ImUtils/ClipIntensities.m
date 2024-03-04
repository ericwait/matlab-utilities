function clippedImage = ClipIntensities(image, minVal, maxVal)
    % clipImage Clips the intensity values of an image to a specified range.
    %
    % This function limits the intensity values of an image to a specified range,
    % clipping any values outside this range to the range's endpoints. If only one
    % endpoint of the range is specified, the function will clip values only at that end.
    %
    % Parameters:
    %   image - The input image to be clipped.
    %   minVal - The minimum intensity value for clipping. If empty or not provided,
    %            clipping is not applied at the lower end.
    %   maxVal - The maximum intensity value for clipping. If empty or not provided,
    %            clipping is not applied at the upper end.
    %
    % Returns:
    %   clippedImage - The resulting image after clipping.

    % Initialize clippedImage with the input image
    clippedImage = image;
    
    % Apply clipping based on provided minVal and maxVal
    if nargin > 1 && ~isempty(minVal)
        clippedImage = max(minVal, clippedImage); % Clip only at the lower end
    end
    if nargin > 2 && ~isempty(maxVal)
        clippedImage = min(clippedImage, maxVal); % Clip only at the upper end
    end
end
