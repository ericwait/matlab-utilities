function imgWithText = AddTextToImageUpperLeft(img, text, padding)
    % AddTextToImageUpperLeft - Overlays text on an image in the upper left corner with optional padding.
    %
    % Parameters:
    %   img - The input image (2D grayscale or 3D RGB).
    %   text - The text string to overlay on the image.
    %   padding (optional) - A 2-element vector specifying the padding from the top and left edges.
    %
    % Returns:
    %   imgWithText - The image with text overlaid in the upper left corner.

    % Check if padding is not provided and set default value
    if nargin < 3
        padding = [10, 10]; % Default padding from the top and left edges
    end
    
    % Ensure img is in uint8 format for consistency in appearance
    if ~isa(img, 'uint8')
        img = im2uint8(img);
    end
    
    % Define the position for the text based on the padding
    position = padding; % Use provided padding for position
    
    % Define text color and background box properties
    textColor = 'white';
    boxColor = 'black';
    
    % Use insertText to add the text to the image
    imgWithText = insertText(img, position, text, 'TextColor', textColor, 'BoxColor', boxColor, 'BoxOpacity', 1, 'FontSize', 12, 'AnchorPoint', 'LeftTop');
    
end
