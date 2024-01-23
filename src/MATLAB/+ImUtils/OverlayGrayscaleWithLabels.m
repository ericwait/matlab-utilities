function overlaidImage = OverlayGrayscaleWithLabels(im_gray, im_label)
    % Check if im_cd8 is a 2D matrix
    if ~ismatrix(im_gray) || size(im_gray,3) ~= 1
        error('im_cd8 must be a 2D grayscale image.');
    end

    % Convert the grayscale image to RGB
    im_rgb = repmat(im_gray, [1, 1, 3]);

    % Generate colored outlines from the labeled image
    % Find boundaries of labeled regions
    boundaries = bwboundaries(im_label, 'noholes');

    % Choose colors for each label
    colors = jet(max(im_label(:))); % Jet colormap for labels

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
end
