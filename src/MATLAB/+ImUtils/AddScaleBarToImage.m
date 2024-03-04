function imgWithScaleBar = AddScaleBarToImage(img, pixelSize, scaleBarLengthInUnits, units, addText)
    % AddScaleBarToImage - Adds a white scale bar to an image, optionally with centered text label above.
    %
    % Parameters:
    %   img - The input image (2D grayscale or 3D RGB).
    %   pixelSize - The size of a pixel in the specified units.
    %   scaleBarLengthInUnits - The desired length of the scale bar in the specified units.
    %   units - The measurement units for pixelSize and scaleBarLengthInUnits.
    %   addText - Boolean flag to indicate whether to add text on top of the scale bar.
    %
    % Returns:
    %   imgWithScaleBar - The image with a white scale bar (and optionally text) added to the bottom right corner.

    % Ensure img is in uint8 format for consistency in appearance
    if ~isa(img, 'uint8')
        img = ImUtils.ConvertType(img, 'uint8', false);
    end
    
    [height, width, numChannels] = size(img);
    if numChannels == 1
        img = repmat(img, [1, 1, 3]); % Convert grayscale to RGB
    end
    
    % Calculate the scale bar length in pixels
    scaleBarPixels = round(scaleBarLengthInUnits / pixelSize);
    
    % Define scale bar height and margins
    scaleBarHeight = 10; % Height of the scale bar in pixels
    marginRight = 20; % Right margin in pixels
    marginBottom = 20; % Bottom margin in pixels
    
    % Calculate scale bar's top left corner position
    topLeftX = width - marginRight - scaleBarPixels;
    topLeftY = height - marginBottom - scaleBarHeight;
    
    % Draw the scale bar on the image
    imgWithScaleBar = img;
    imgWithScaleBar(topLeftY:(topLeftY+scaleBarHeight-1), topLeftX:(topLeftX+scaleBarPixels-1), :) = 255;
    
    % Add text label on top of the scale bar if requested
    if addText
        text = [num2str(scaleBarLengthInUnits), ' ', units];
        % Estimate the text position for centering above the scale bar
        textPositionX = round(topLeftX + scaleBarPixels / 2);
        textPositionY = topLeftY - 15; % Adjust as needed to position above the scale bar
        
        % Use insertText for adding the label. Adjust 'BoxOpacity' and 'TextColor' as needed.
        imgWithScaleBar = insertText(imgWithScaleBar, [textPositionX, textPositionY], text, 'AnchorPoint', 'Center', ...
                                     'BoxOpacity', 0, 'TextColor', 'white', 'FontSize', 12);
    end
end
