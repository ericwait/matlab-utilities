function overlaidImage = OverlayGrayscaleWithLabels(im_gray, im_label, add_labels, dilationThickness)
% OverlayGrayscaleWithLabels overlays colored boundary outlines and, optionally, labels on a grayscale image.
% This function takes a grayscale image and a labeled image as inputs. It generates an RGB image where
% boundaries of labeled regions are overlaid on the original grayscale image in different colors. Optionally,
% numerical labels can be added to each region. The thickness of the boundary lines can be adjusted through
% an additional parameter.
%
% Usage:
%   overlaidImage = OverlayGrayscaleWithLabels(im_gray, im_label, add_labels, dilationThickness)
%
% Inputs:
%   im_gray - A 2D grayscale image (matrix of class uint8, uint16, double, etc.).
%   im_label - A labeled image matrix of the same size as im_gray, where each object has a unique integer label.
%   add_labels - (Optional) A logical flag indicating whether to add numerical labels to the regions in the overlaid image.
%                If true, labels are added. If omitted or false, no labels are added.
%   dilationThickness - (Optional) An integer specifying the thickness of the boundary lines. This parameter
%                       controls the thickness of the lines by dilating them. If provided and greater than 0,
%                       the boundary lines will be made thicker accordingly. Defaults to 0 (original thickness) if not provided.
%
% Outputs:
%   overlaidImage - An RGB image of the same size as im_gray, with overlaid colored boundaries and, optionally, numerical labels.
%
% Examples:
%   overlaidImg = OverlayGrayscaleWithLabels(grayImage, labelImage);
%   This call overlays colored boundaries on the grayscale image without altering the line thickness or adding labels.
%
%   overlaidImg = OverlayGrayscaleWithLabels(grayImage, labelImage, true, 2);
%   This example overlays colored boundaries, made thicker by a dilation thickness of 2 pixels, and numerical labels on the grayscale image.
%
% Notes:
%   - The function validates that im_gray is a 2D grayscale image.
%   - The boundary colors are determined using MATLAB's 'lines' colormap, and the boundaries are optionally dilated to increase visibility.
%   - If `dilationThickness` is provided and greater than 0, the function makes the boundary lines thicker by the specified amount before overlaying them on the image.
%     This can be useful for making boundaries more visible or for artistic effects.
%   - Adding labels to regions requires that 'im_label' has distinct labels for different regions.

    % Validate input image is 2D and grayscale
    if ~ismatrix(im_gray) || size(im_gray,3) ~= 1
        error('im_gray must be a 2D grayscale image.');
    end

    % Ensure the image is of type uint8
    im_gray = ImUtils.ConvertType(im_gray, 'uint8', false);
    
    % Convert the grayscale image to RGB
    im_rgb = repmat(im_gray, [1, 1, 3]);

    % Generate colored outlines from the labeled image
    boundaries = bwboundaries(im_label, 'holes');

    % Choose colors for each label
    colors = lines(max(im_label(:))); % lines colormap for labels

    % Overlay boundaries on the grayscale image
    for k = 1:length(boundaries)
        boundary = boundaries{k};

        % Dilate the boundary lines if dilationThickness > 0
        if nargin > 3 && dilationThickness > 0
            dilatedBoundary = dilateBoundary(boundary, dilationThickness, size(im_gray));
        else
            dilatedBoundary = boundary;
        end

        % Overlay dilated boundary on RGB image
        for l = 1:size(dilatedBoundary, 1)
            colorInd = im_label(boundary(1,1), boundary(1,2));
            if colorInd > 0
                im_rgb(dilatedBoundary(l,1), dilatedBoundary(l,2), :) = uint8(colors(colorInd, :) * 255);
            end
        end
    end

    % Return the overlaid image
    overlaidImage = im_rgb;

    if nargin > 2 && add_labels
        % Adding labels to the regions
        addRegionLabels(im_label, overlaidImage);
    end
end

function dilatedBoundary = dilateBoundary(boundary, dilationThickness, imageSize)
    % Create an empty image matrix
    boundaryImg = false(imageSize(1), imageSize(2));
    
    % Mark the boundary points on the image
    ind = sub2ind(imageSize, boundary(:,1), boundary(:,2));
    boundaryImg(ind) = true;
    
    % Dilate the boundary image to make the lines thicker
    se = strel('disk', dilationThickness);
    dilatedBoundaryImg = imdilate(boundaryImg, se);
    
    % Find the coordinates of the dilated boundary
    [y, x] = find(dilatedBoundaryImg);
    dilatedBoundary = [y, x];
end

function addRegionLabels(im_label, overlaidImage)
    stats = regionprops(im_label, 'BoundingBox');
    % Create an invisible figure
    f = figure('visible', 'off');

    % Display the image in this off-screen figure
    imshow(overlaidImage); % Display the image
    hold on;

    % Overlay text at the lower right corner of each bounding box
    for i = 1:numel(stats)
        bbox = stats(i).BoundingBox;
        % Calculate the lower right corner of the bounding box
        lowerRightCornerX = bbox(1) + bbox(3); % X-coordinate
        lowerRightCornerY = bbox(2) + bbox(4); % Y-coordinate

        text(lowerRightCornerX, lowerRightCornerY, sprintf('%d', i), ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', ...
            'FontSize', 6, 'Color', 'r');
    end
    
    hold off;

    % Ensure the axes limits are set correctly
    axis tight;
    axis on; % Temporarily turn on the axis to ensure 'getframe' captures the whole image

    % Save the figure to a file
    im_frame = getframe(gca);
    overlaidImage = im_frame.cdata;
    
    % Close the figure
    close(f);
end
