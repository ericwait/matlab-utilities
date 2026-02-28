function [X, Y, Z] = combine_letters(letters, resolution, spacing)
% COMBINE_LETTERS Combines multiple letters into one surface
%
% Inputs:
%   letters - Cell array of letters (e.g., {'E', 'W'})
%   resolution - Grid resolution per letter (default: 300)
%   spacing - Distance between letter centers (default: 2.5)
%
% Outputs:
%   X, Y, Z - Combined meshgrid coordinates

    if nargin < 2
        resolution = 300;
    end
    if nargin < 3
        spacing = 2.5;
    end
    
    num_letters = length(letters);
    
    % Each letter occupies a 2x2 space, calculate offsets
    offsets = zeros(num_letters, 2);
    total_width = (num_letters - 1) * spacing;
    start_x = -total_width / 2;
    
    for i = 1:num_letters
        offsets(i, 1) = start_x + (i - 1) * spacing;
        offsets(i, 2) = 0;
    end
    
    % Generate each letter surface
    X_all = cell(num_letters, 1);
    Y_all = cell(num_letters, 1);
    Z_all = cell(num_letters, 1);
    
    for i = 1:num_letters
        [X_all{i}, Y_all{i}, Z_all{i}] = Art.create_letter_surface(...
            letters{i}, resolution, offsets(i, :));
    end
    
    % Concatenate horizontally
    X = [X_all{:}];
    Y = [Y_all{:}];
    Z = [Z_all{:}];
    
    % Clip to content with small padding
    threshold = 0.01; % Minimum height to consider
    padding = 0.2; % Extra space around letters
    
    % Find bounds in X direction
    x_has_content = any(Z > threshold, 1);
    x_indices = find(x_has_content);
    if ~isempty(x_indices)
        x_min_idx = max(1, x_indices(1) - round(padding * resolution / 2));
        x_max_idx = min(size(X, 2), x_indices(end) + round(padding * resolution / 2));
    else
        x_min_idx = 1;
        x_max_idx = size(X, 2);
    end
    
    % Find bounds in Y direction
    y_has_content = any(Z > threshold, 2);
    y_indices = find(y_has_content);
    if ~isempty(y_indices)
        y_min_idx = max(1, y_indices(1) - round(padding * resolution / 2));
        y_max_idx = min(size(Y, 1), y_indices(end) + round(padding * resolution / 2));
    else
        y_min_idx = 1;
        y_max_idx = size(Y, 1);
    end
    
    % Crop to bounds
    X = X(y_min_idx:y_max_idx, x_min_idx:x_max_idx);
    Y = Y(y_min_idx:y_max_idx, x_min_idx:x_max_idx);
    Z = Z(y_min_idx:y_max_idx, x_min_idx:x_max_idx);
    
end