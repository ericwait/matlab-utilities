function im_rgb = MakeBoundaryImage(im_gray, im_label, colors, dilationThickness)
    % OVERLAYBOUNDARIES Overlays colored boundaries on a grayscale image.
    %
    %   im_rgb = overlayBoundaries(im_gray, im_label, colors, dilationThickness)
    %   overlays the boundaries from the labeled image im_label onto the
    %   grayscale image im_gray. The colors for each label are specified in
    %   the colors matrix. Optionally, the boundaries can be dilated by
    %   dilationThickness pixels.
    %
    % Inputs:
    %   - im_gray: Grayscale image to overlay boundaries on.
    %   - im_label: Labeled image with integer labels for each region.
    %   - colors: Nx3 matrix of RGB colors for each label.
    %   - dilationThickness: Optional parameter specifying the thickness
    %     to dilate the boundaries. If not provided or <= 0, no dilation is applied.
    %
    % Output:
    %   - im_rgb: RGB image with overlaid boundaries.

    numLabels = max(im_label(:));
    if ~exist("colors", "var") || isempty(colors)
        colors = ones(numLabels, 3);
    elseif size(colors, 2) ~= 3
        error('Colors must be a row vector with three scalars between [0,1]');
    elseif size(colors,1) ~= numLabels
        colors = repmat(colors(1,1:3), [numLabels, 1]);
    end

    % Generate colored outlines from the labeled image
    boundaries = bwboundaries(im_label, 'holes');

    % Ensure the image is of type uint8
    im_gray = ImUtils.ConvertType(im_gray, 'uint8', false);

    % Convert grayscale image to RGB
    im_rgb = repmat(im_gray, [1, 1, 3]);

    % Overlay boundaries on the RGB image
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
            colorInd = im_label(boundary(1, 1), boundary(1, 2));
            if colorInd > 0
                im_rgb(dilatedBoundary(l, 1), dilatedBoundary(l, 2), :) = uint8(colors(colorInd, :) * 255);
            end
        end
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