function [resizedImage, newPixelSizes] = ResizeNDImage(imageData, pixelSizes, resizeFactors)
% ResizeNDImage Resizes an N-dimensional image using specified resize factors.
%
%   [resizedImage, newPixelSizes] = ResizeNDImage(imageData, pixelSizes, resizeFactors)
%
%   This function resizes the input image data in the first two or three dimensions
%   according to the specified resize factors. It handles higher-dimensional images
%   by recursively applying the resizing operation over additional dimensions.
%
%   Inputs:
%       imageData     - An N-dimensional array representing the image data.
%       pixelSizes    - A vector of length N specifying the pixel size in each dimension.
%       resizeFactors - A vector specifying the resize factors for the first 2 or 3 dimensions.
%                       The length of resizeFactors must be 2 or 3.
%
%   Outputs:
%       resizedImage  - The resized image data array.
%       newPixelSizes - A vector of length N containing the new pixel sizes after resizing.
%
%   Example:
%       % Original image data and pixel sizes
%       imageData = rand(256, 256, 50);       % Example 3D image
%       pixelSizes = [0.5, 0.5, 1.0];         % Pixel sizes in each dimension
%
%       % Resize factors for the first two dimensions
%       resizeFactors = [0.5, 0.5];           % Reduce size by half in X and Y
%
%       % Resize the image
%       [resizedImage, newPixelSizes] = ResizeNDImage(imageData, pixelSizes, resizeFactors);
%
%       % Display new pixel sizes
%       disp(newPixelSizes);
%
%   Notes:
%       - The function uses imresize for 2D images and imresize3 for 3D images.
%       - For images with more than 3 dimensions, the function recursively resizes
%         along the additional dimensions.
%       - The length of pixelSizes must match the number of dimensions in imageData.
%       - The resizeFactors should have a length of 2 or 3, corresponding to the
%         dimensions to be resized.
%
%   See also: imresize, imresize3

    % Get the number of dimensions of the input image
    numDims = ndims(imageData);

    % Validate inputs
    if length(pixelSizes) ~= numDims
        error('The length of pixelSizes must match the number of dimensions in imageData.');
    end
    if length(resizeFactors) < 2 || length(resizeFactors) > 3
        error('resizeFactors must be a vector of length 2 or 3.');
    end

    % Initialize the new pixel sizes
    newPixelSizes = pixelSizes;

    % Handle 2D or 3D resizing
    if length(resizeFactors) == 2
        % Resize the first two dimensions using imresize
        % Create an anonymous function to apply imresize to the image
        resizeFcn = @(img) imresize(img, resizeFactors(1:2));

        % Scale factors for adjusting pixel sizes
        scaleFactors = [resizeFactors(1:2), ones(1, numDims - 2)];
    elseif length(resizeFactors) == 3
        % Resize the first three dimensions using imresize3
        resizeFcn = @(img) imresize3(img, resizeFactors(1:3));

        % Scale factors for adjusting pixel sizes
        scaleFactors = [resizeFactors(1:3), ones(1, numDims - 3)];
    end

    % Initialize the resized image with the original image data
    resizedImage = imageData;

    % Check if the image has more dimensions than resizeFactors
    if numDims > length(resizeFactors)
        % Get the dimensions beyond those resized directly
        otherDims = (length(resizeFactors) + 1):numDims;

        % Recursively resize along the additional dimensions
        resizedImage = iterResize(resizedImage, resizeFcn, otherDims);
    else
        % If all dimensions are covered by resizeFactors, apply resizeFcn directly
        resizedImage = resizeFcn(imageData);
    end

    % Update the pixel sizes for the resized dimensions
    newPixelSizes(1:length(resizeFactors)) = pixelSizes(1:length(resizeFactors)) ./ resizeFactors;

    % Nested function to recursively resize over specified dimensions
    function img = iterResize(img, resizeFcn, dims)
        % Base case: if no more dimensions to iterate over, apply resize function
        if isempty(dims)
            img = resizeFcn(img);
        else
            % Recursive case: iterate over the first dimension in dims
            dim = dims(1);                     % Current dimension to process
            numSlices = size(img, dim);        % Number of slices along the current dimension
            idx = repmat({':'}, 1, numDims);   % Initialize index cell array for all dimensions

            % Loop over each slice in the current dimension
            for i = 1:numSlices
                idx{dim} = i;  % Set index for the current dimension
                % Recursively call iterResize on each slice
                img(idx{:}) = iterResize(img(idx{:}), resizeFcn, dims(2:end));
            end
        end
    end
end
