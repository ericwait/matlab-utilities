function img = AddScaleBarToImage(img, pixelSize, scaleBarLengthInUnits, units, addText, padding)
    % AddScaleBarToImage Adds a scale bar and optionally a text label to an image.
    %
    % This function overlays a scale bar onto the given image at a specified location.
    % It can also add a textual label above the scale bar to denote its length in specific units.
    % The function is designed to preserve the original image's data type and dynamic range.
    %
    % Parameters:
    %   img - Input image (2D grayscale or 3D RGB).
    %   pixelSize - The size of a pixel in the specified units (e.g., micrometers per pixel).
    %   scaleBarLengthInUnits - The desired physical length of the scale bar in the given units.
    %   units - A string representing the units of the scale bar length (e.g., 'μm').
    %   addText - Boolean indicating whether to add a text label for the scale bar length.
    %   padding - Optional; a 2-element vector [rightPadding, bottomPadding] specifying the padding 
    %             from the right and bottom edges for the scale bar placement. Default is [10, 10].
    %
    % Returns:
    %   img - The modified image with the scale bar (and optionally text) added.

    % Check if padding is not provided and set default values
    if nargin < 6
        padding = [10, 10]; % Default padding from the right and bottom edges
    end

    % Determine the maximum intensity value based on the image's data type
    maxValue = max(img(:)); % Use the maximum value in the image for drawing the scale bar and text

    % Obtain the dimensions of the image
    [rows, cols, channels] = size(img);
    
    % Calculate the length of the scale bar in pixels based on the physical size
    scaleBarPixels = round(scaleBarLengthInUnits / pixelSize);

    % Define the height of the scale bar in pixels and the margins
    scaleBarHeight = 10; % Height of the scale bar
    marginBottom = padding(2); % Bottom margin in pixels for scale bar placement
    marginRight = padding(1); % Right margin in pixels for scale bar placement

    % Calculate the top-left position of the scale bar based on the image size and padding
    topLeftX = cols - marginRight - scaleBarPixels;
    topLeftY = rows - marginBottom - scaleBarHeight;
    
    % Initialize a mask for the scale bar with the same number of channels as the input image
    scaleBarMask = false(rows, cols, max(channels,1));
    scaleBarMask(topLeftY:(topLeftY+scaleBarHeight-1), topLeftX:(topLeftX+scaleBarPixels-1), :) = true;
    
    % Apply the scale bar mask to the image by setting the corresponding pixels to the maximum value
    img(scaleBarMask) = maxValue;

    % Add a text label above the scale bar if requested
    if addText
        % Create a blank canvas for the text overlay
        blankCanvas = zeros(rows, cols, 'uint8');
        textStr = [num2str(scaleBarLengthInUnits), ' ', units];
        textPosition = [topLeftX + scaleBarPixels / 2, topLeftY - padding(2) - scaleBarHeight];
        
        % Overlay the text onto the blank canvas
        imgWithText = insertText(blankCanvas, textPosition, textStr, ...
                                 'FontSize', 12, 'BoxOpacity', 0, ...
                                 'TextColor', 'white', 'AnchorPoint', 'Center');
        
        % Convert the inserted text to a binary mask
        textMask = rgb2gray(imgWithText) > 0;
        
        % Apply the text mask to the original image, setting text pixels to the maximum value
        img(repmat(textMask,[1,1,channels])) = maxValue;
    end
end
