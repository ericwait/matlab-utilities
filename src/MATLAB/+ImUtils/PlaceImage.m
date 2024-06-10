function outputImage = PlaceImage(baseImage, insertImage, varargin)
    % placeImage Places an insert image within a base image.
    % 
    % outputImage = placeImage(baseImage, insertImage)
    % outputImage = placeImage(baseImage, insertImage, 'position')
    % outputImage = placeImage(baseImage, insertImage, 'position', 'startIdx', startIdx)
    %
    % This function places the insertImage within the baseImage. The
    % insertImage can have dimensions ranging from 2 to ndims(baseImage).
    % 
    % Inputs:
    % - baseImage: The larger image where the insert image will be placed.
    % - insertImage: The image to be placed within the base image.
    % - position: (Optional) A string specifying the default position to 
    %   place the insert image. Possible values are 'center', 'top-left',
    %   'top-right', 'bottom-left', and 'bottom-right'. Default is 'center'.
    % - startIdx: (Optional) A vector specifying the starting indices for 
    %   placing the insert image. If any value in startIdx is less than 1,
    %   the corresponding dimension will use the default position.
    % 
    % Output:
    % - outputImage: The resulting image with the insert image placed within 
    %   the base image.
    % 
    % Example usage:
    % outputImage = placeImage(baseImage, insertImage);
    % outputImage = placeImage(baseImage, insertImage, 'top-left');
    % outputImage = placeImage(baseImage, insertImage, 'center', 'startIdx', [0, 0, 12, 1]);
    
    % Validate input dimensions
    if ndims(insertImage) < 2 || ndims(insertImage) > ndims(baseImage)
        error('The insert image must have dimensions between 2 and the number of dimensions of the base image.');
    end
    
    % Set up input parser
    p = inputParser;
    addOptional(p, 'position', 'center');
    addParameter(p, 'startIdx', []);
    
    parse(p, varargin{:});
    position = p.Results.position;
    startIdxInput = p.Results.startIdx;
    
    % Get the size of the base and insert images
    baseSize = size(baseImage);
    insertSize = size(insertImage);
    
    % Initialize starting indices based on the specified position
    startIdx = ones(1, ndims(baseImage));
    switch position
        case 'center'
            for dim = 1:ndims(insertImage)
                startIdx(dim) = ceil((baseSize(dim) - insertSize(dim)) / 2) + 1;
            end
        case 'top-left'
            startIdx = ones(1, ndims(baseImage));
        case 'top-right'
            startIdx(1) = 1;
            startIdx(2) = baseSize(2) - insertSize(2) + 1;
        case 'bottom-left'
            startIdx(1) = baseSize(1) - insertSize(1) + 1;
            startIdx(2) = 1;
        case 'bottom-right'
            startIdx(1) = baseSize(1) - insertSize(1) + 1;
            startIdx(2) = baseSize(2) - insertSize(2) + 1;
        otherwise
            error('Invalid position specified. Use "center", "top-left", "top-right", "bottom-left", or "bottom-right".');
    end
    
    % Replace dimensions with explicit startIdx if provided and valid
    if ~isempty(startIdxInput)
        for dim = 1:length(startIdxInput)
            if startIdxInput(dim) >= 1
                startIdx(dim) = startIdxInput(dim);
            end
        end
    end
    
    % Calculate the ending indices
    endIdx = startIdx + insertSize - 1;
    
    % Adjust indices if they are out of bounds
    for dim = 1:length(startIdx)
        if startIdx(dim) < 1
            startIdx(dim) = 1;
        end
        if endIdx(dim) > baseSize(dim)
            endIdx(dim) = baseSize(dim);
        end
    end
    
    % Adjust the insertSize if the insertImage will be cropped
    adjustedInsertSize = endIdx - startIdx + 1;
    for dim = 1:ndims(insertImage)
        if adjustedInsertSize(dim) > insertSize(dim)
            adjustedInsertSize(dim) = insertSize(dim);
        end
    end
    
    % Initialize the output image as the base image
    outputImage = baseImage;
    
    % Place the insert image within the base image
    if ismatrix(insertImage)
        outputImage(startIdx(1):endIdx(1), startIdx(2):endIdx(2)) = insertImage(1:adjustedInsertSize(1), 1:adjustedInsertSize(2));
    else
        insertIndices = cell(1, ndims(baseImage));
        for dim = 1:ndims(insertImage)
            insertIndices{dim} = startIdx(dim):endIdx(dim);
        end
        if ndims(insertImage) < ndims(baseImage)
            for dim = ndims(insertImage) + 1:ndims(baseImage)
                insertIndices{dim} = 1:baseSize(dim);
            end
        end
        outputImage(insertIndices{:}) = insertImage(1:adjustedInsertSize(1), 1:adjustedInsertSize(2), :);
    end
    
    % Return the output image
end