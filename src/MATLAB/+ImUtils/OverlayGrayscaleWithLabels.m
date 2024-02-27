function overlaidImage = OverlayGrayscaleWithLabels(im_gray, im_label, add_labels)
    % Check if im_cd8 is a 2D matrix
    if ~ismatrix(im_gray) || size(im_gray,3) ~= 1
        error('im_cd8 must be a 2D grayscale image.');
    end

    im_gray = ImUtils.ConvertType(im_gray, 'uint8', false);
    % Convert the grayscale image to RGB
    im_rgb = repmat(im_gray, [1, 1, 3]);

    % Generate colored outlines from the labeled image
    % Find boundaries of labeled regions
    boundaries = bwboundaries(im_label, 'noholes');

    % Choose colors for each label
    colors = lines(max(im_label(:))); % lines colormap for labels

    % Overlay boundaries on the grayscale image
    for k = 1:length(boundaries)
        boundary = boundaries{k};

        % Get a color for this label
        color = colors(im_label(boundary(1,1), boundary(1,2)), :);

        % Overlay boundary on RGB image
        for l = 1:size(boundary, 1)
            im_rgb(boundary(l,1), boundary(l,2), :) = uint8(color * 255);
        end
    end

    % Return the overlaid image
    overlaidImage = im_rgb;

    if nargin > 2 && add_labels
        stats = regionprops(im_label, 'BoundingBox');
        % Create an invisible figure
        f = figure('visible', 'off');
        
        % Display the image in this off-screen figure
        imshow(overlaidImage);%, 'InitialMagnification', 'fit'); % Display the image
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

end