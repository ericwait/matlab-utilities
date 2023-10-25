function zStackIndices = FindZStackIndices(positions, precision)
    % findZStackIndices - Find indices of unique XY points representing z-stacked images
    %
    % Syntax:
    % zStackIndices = findZStackIndices(positions)
    % zStackIndices = findZStackIndices(positions, precision)
    %
    % Inputs:
    % positions - M x 3 matrix, where each row contains the (x, y, z) position
    % precision - Optional, precision for x, y comparison (default = 1e-5)
    %
    % Outputs:
    % zStackIndices - Cell array containing the indices of the unique XY points
    
    if nargin < 2
        precision = 1e-5;  % Default precision
    end

    % Round x,y coordinates to the given precision
    xy_positions = round(positions(:, 1:2) / precision) * precision;
    
    % Find unique XY points
    [uniqueXY, ~, ic] = unique(xy_positions, 'rows', 'stable');
    
    % Initialize cell array to hold indices
    zStackIndices = cell(size(uniqueXY, 1), 1);
    
    % Populate cell array with indices of each unique XY point
    for i = 1:size(uniqueXY, 1)
        zStackIndices{i} = find(ic == i);
    end
end
