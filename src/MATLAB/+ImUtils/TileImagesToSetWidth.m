function stitchedImg = TileImagesToSetWidth(images, maxWidth)
    % TileImagesToSetWidth - Stitches a cell array of images into a single image.
    %
    % This function arranges images stored in a cell array into a single large
    % image with a specified maximum width. Images are tiled vertically and
    % horizontally, respecting the maximum width, with new rows created as necessary.
    % A 50% gray border of 5 pixels is added between images. The final image is
    % padded with black to meet the maximum width constraint and ensure uniform row heights.
    %
    % Parameters:
    %   images - A cell array of RGB images (3D matrices).
    %   maxWidth - The maximum width of the resulting stitched image.
    %
    % Returns:
    %   stitchedImg - The resulting stitched image as an RGB image (3D matrix).
    
    % Initialize variables for storing image dimensions and tracking row ends
    numImages = numel(images); % Total number of images
    sizes = zeros(numImages, 2); % Array to store dimensions of each image (height, width)
    rowEnds = []; % Array to store indices of the last image in each row
    maxWidthUsed = 0; % To track the maximum width used across all rows

    images = cellfun(@(x)(ImUtils.ConvertType(x, 'uint8', false)), images, 'UniformOutput', false);
    
    % Loop through images to store their sizes
    for i = 1:numImages
        sizes(i, :) = [size(images{i}, 1), size(images{i}, 2)]; % Store height and width
    end
    
    % Determine the end of each row based on maxWidth
    currentWidth = 0; % Track the current width accumulation
    for i = 1:numImages
        imageWidthWithBorder = sizes(i, 2) + 5; % Include border in width calculation
        if i == 1 || currentWidth + imageWidthWithBorder > maxWidth
            if i > 1
                rowEnds = [rowEnds, i-1]; % Mark the end of the current row
            end
            currentWidth = sizes(i, 2); % Reset currentWidth for the new row
        else
            currentWidth = currentWidth + imageWidthWithBorder; % Accumulate width with border
        end
    end
    rowEnds = [rowEnds, numImages]; % Ensure the last image ends the final row
    
    % Calculate the total height required for the stitched image, including borders
    totalHeight = 0;
    rowStarts = [1, rowEnds(1:end-1)+1];
    for i = 1:numel(rowEnds)
        rowHeight = max(sizes(rowStarts(i):rowEnds(i), 1)); % Max height in the row
        if i > 1
            totalHeight = totalHeight + 5; % Add border space for subsequent rows
        end
        totalHeight = totalHeight + rowHeight; % Accumulate total height
    end
    
    % Initialize the stitched image canvas with 50% gray background
    stitchedImg = uint8(ones(totalHeight + 5 * (numel(rowEnds) - 1), maxWidth, 3) * 128);

    % Tile images onto the canvas
    currentY = 1;
    for i = 1:numel(rowEnds)
        rowHeight = max(sizes(rowStarts(i):rowEnds(i), 1));
        currentX = 1;
        maxWidthForRow = 0; % To track the used width in the current row
        
        for j = rowStarts(i):rowEnds(i)
            img = images{j};
            [h, w, c] = size(img);

            % Convert grayscale to RGB if necessary
            if c == 1
                img = repmat(img, [1, 1, 3]);
            end

            % Adjust for border and placement
            if currentX + w + 5 > maxWidth
                w = maxWidth - currentX - 4;
            end
            
            % Place the image into the stitched image
            stitchedImg(currentY:(currentY + h - 1), currentX:(currentX + w - 1), :) = img(1:h, 1:w, :);
            currentX = currentX + w + 5; % Include border for next image
            
            % Update maxWidthForRow
            maxWidthForRow = currentX - 5; % Exclude the border for the row's end

            if currentX > maxWidth
                break;
            end
        end
        
        % Update maxWidthUsed if the current row is wider
        maxWidthUsed = max(maxWidthUsed, maxWidthForRow);
        currentY = currentY + rowHeight + 5; % Move to the next row, include border
    end
    
    % Crop the stitched image to remove excess gray border on the right
    maxY = min(currentY, totalHeight);
    stitchedImg = stitchedImg(1:maxY, 1:maxWidthUsed, :);
end
