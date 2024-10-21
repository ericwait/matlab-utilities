function imOut = CropDataToRange(imIn, minVal, maxVal)
    % CropDataToRange Crops an N-D matrix by removing planes, cubes, or 
    % hypercubes of all zero values (or values outside the specified range).
    %
    % This function removes slices along any dimension that consist entirely
    % of zero (or out-of-bound) values, effectively shrinking the matrix
    % while preserving the data inside the specified value range.
    %
    % Usage:
    % imOut = CropDataToRange(imIn, minVal, maxVal)
    %
    % Inputs:
    %   imIn   - N-D input matrix (can be 2D, 3D, or higher-dimensional).
    %   minVal - (optional) Minimum value for the valid data range. Any values
    %            less than this will be treated as zeros. Default is 0.
    %   maxVal - (optional) Maximum value for the valid data range. Any values
    %            greater than this will be treated as zeros. Default is inf.
    %
    % Output:
    %   imOut  - Cropped N-D matrix with zero-valued planes removed along any
    %            dimension.
    
    % Handle optional arguments for minVal and maxVal
    if nargin < 2 || isempty(minVal)
        minVal = 0; % Default minVal is 0
    end
    if nargin < 3 || isempty(maxVal)
        maxVal = inf; % Default maxVal is inf
    end

    % Create a mask for elements that are within the valid range [minVal, maxVal]
    imInBounds = (imIn >= minVal & imIn <= maxVal);
    
    % Initialize the output as the input matrix
    imOut = imIn;

    % Loop through each dimension of the matrix to crop along that dimension
    for dim = 1:ndims(imIn)
        % Calculate the maximum across all dimensions except the current one
        % This gives a mask that tells which slices along the current dimension
        % have any valid data (i.e., data within the range [minVal, maxVal])
        otherDims = setdiff(1:ndims(imIn), dim);
        imKeepMask = max(imInBounds, [], otherDims);

        % If all slices along this dimension contain valid data, skip cropping
        if nnz(~imKeepMask) == 0
            continue
        end

        % Determine the indices of slices along this dimension that contain valid data
        indices = repmat({':'}, 1, ndims(imIn)); % Initialize indices with ':' for all dimensions
        indices{dim} = find(imKeepMask); % Find the slices to keep in the current dimension

        % Crop the matrix along the current dimension using the calculated indices
        imOut = imOut(indices{:});
        
        % Also crop the bounds mask to keep it aligned with the reduced matrix
        imInBounds = imInBounds(indices{:});
    end
end
