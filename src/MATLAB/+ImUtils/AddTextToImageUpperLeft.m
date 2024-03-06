function img = AddTextToImageUpperLeft(img, titleText, padding)
    % AddTextToImageUpperLeft Overlays text on an image in the upper left corner.
    %
    % This function overlays specified text onto an image at a position determined by padding.
    % The function is designed to work with both grayscale and RGB images, preserving the
    % original image's data type and dynamic range by setting the text pixels to the maximum
    % intensity value found in the image.
    %
    % Parameters:
    %   img - Input image (2D grayscale or 3D RGB) to overlay text onto.
    %   titleText - The text string to be overlaid onto the image.
    %   padding - Optional; A 2-element vector [horizontalPadding, verticalPadding] specifying the
    %             padding from the top and left edges of the image. Default is [10, 10].
    %
    % Returns:
    %   img - The modified image with the text overlaid in the upper left corner.
    
    % Validate input arguments and set default padding if not provided
    if nargin < 3
        padding = [10, 10]; % Default padding from the top and left edges
    end

    % Determine the maximum intensity value in the image to use for the text
    maxValue = max(img(:));

    % Obtain the dimensions of the image
    [rows, cols, ~] = size(img);
    
    % Create a blank RGB image for adding text. This temporary RGB canvas is used
    % to leverage the insertText function, which requires an RGB or uint8 image.
    blankRGB = zeros(rows, cols, 3, 'uint8');
    
    % Overlay the specified text onto the blank RGB canvas
    textRGB = insertText(blankRGB, padding, titleText, ...
                         'TextColor', 'white', 'BoxOpacity', 0, ...
                         'FontSize', 12, 'AnchorPoint', 'LeftTop');
    
    % Convert the RGB image with the text overlay to a binary mask. The mask identifies
    % where the text pixels are located based on the change from the blank canvas.
    textMask = any(textRGB > 0, 3);

    % Apply the binary mask to the original image. Wherever the mask is true (where text
    % pixels exist), set those pixels in the original image to its maximum intensity value.
    % This effectively "draws" the text onto the image using the maximum intensity,
    % ensuring visibility regardless of the original image's dynamic range.
    if ismatrix(img) % Check if the image is grayscale (2D matrix)
        img(textMask) = maxValue;
    else % For RGB images, apply the mask to all color channels
        for channel = 1:size(img, 3)
            imgChannel = img(:,:,channel);
            imgChannel(textMask) = maxValue;
            img(:,:,channel) = imgChannel;
        end
    end
end
