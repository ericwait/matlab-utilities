function [X, Y, Z] = create_letter_surface(letter, resolution, offset)
% CREATE_LETTER_SURFACE Creates a 3D embossed surface of a letter
%
% Inputs:
%   letter - Character to render (e.g., 'E', 'W')
%   resolution - Grid resolution (default: 300)
%   offset - [x_offset, y_offset] to shift the letter (default: [0, 0])
%
% Outputs:
%   X, Y, Z - Meshgrid coordinates for surface plotting

    if nargin < 2
        resolution = 300;
    end
    if nargin < 3
        offset = [0, 0];
    end
    
    % Create a high-res grid
    [X, Y] = meshgrid(linspace(-1, 1, resolution), linspace(-1, 1, resolution));
    
    % Apply offset
    X = X + offset(1);
    Y = Y + offset(2);
    
    % Create text mask at higher resolution for better quality
    temp_res = resolution * 2;
    fig = figure('Visible', 'off', 'Position', [0 0 temp_res temp_res]);
    ax = axes('Parent', fig, 'Position', [0 0 1 1]);
    text(0.5, 0.5, letter, ...
        'FontSize', 200, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Units', 'normalized', ...
        'FontName', 'Arial');
    axis off;
    xlim([0 1]); ylim([0 1]);
    %set(gca, 'YDir', 'reverse');
    
    % Capture as image
    frame = getframe(ax);
    letter_img = mat2gray(rgb2gray(frame.cdata));
    close(fig);

    % Flip vertically to correct orientation
    letter_img = flipud(letter_img);
    
    % Resize to match grid
    letter_mask = imresize(letter_img, [resolution, resolution]);
    letter_mask = 1 - (letter_mask / max(letter_mask(:))); % Invert and normalize
    
    % Threshold to get clean binary mask
    letter_binary = letter_mask > 0.3;
    
    % Method 1: Use the mask directly with smoothing
    Z = double(letter_binary);
    
    % Apply heavy Gaussian blur to create smooth mounds
    sigma = resolution / 50; % Adjust for smoothness
    Z = imgaussfilt(Z, sigma);
    
    % Normalize
    Z = Z / max(Z(:));
    
    % Apply power law for better shape
    Z = Z.^1.5;
    
end
