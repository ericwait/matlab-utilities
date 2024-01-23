function [xyGroups, xyzGroups] = FindDuplicatePoints(pointMatrix, precision)
    % FINDDUPLICATEPOINTS Groups points based on matching coordinates.
    % 
    %   [xyGroups, xyzGroups] = FINDDUPLICATEPOINTS(pointMatrix) groups points 
    %   from 'pointMatrix', where each row represents a point and columns 
    %   represent the dimensions (x, y, z). It returns two arrays: 'xyGroups' 
    %   and 'xyzGroups'. 'xyGroups' contains group labels for points that have 
    %   matching x and y coordinates. 'xyzGroups' contains labels for points 
    %   that match in all three dimensions (x, y, z).
    %
    %   [xyGroups, xyzGroups] = FINDDUPLICATEPOINTS(pointMatrix, precision) 
    %   allows specifying 'precision', which determines the level of precision 
    %   to consider when comparing points. If 'precision' is a scalar, it is 
    %   applied to all dimensions. If it is a vector, it applies each element 
    %   to the corresponding dimension. The default value is 1e-10.
    %
    %   Example:
    %   pointMatrix = [1, 1, 1; 1, 1, 2; 1, 1, 1];
    %   [xyGroups, xyzGroups] = findDuplicatePoints(pointMatrix)
    %
    %   See also UNIQUE, ROUND.

    % Default precision
    if nargin < 2
        precision = 1e-10;
    end
    
    % Apply precision
    if isscalar(precision)
        pointMatrixRounded = round(pointMatrix, -log10(precision));
    else
        pointMatrixRounded = round(pointMatrix, -log10(precision(:)'));
    end

    % Group points based on x, y coordinates
    [~, ~, xyGroups] = unique(pointMatrixRounded(:, 1:2), 'rows', 'stable');

    % Group points based on x, y, z coordinates
    [~, ~, xyzGroups] = unique(pointMatrixRounded, 'rows', 'stable');
end
