function im = AdjustImageDimensions(im, desiredParity)
%ADJUSTIMAGEDIMENSIONS Adjusts the dimensions of an image to be odd or even as specified.
%
% Syntax:
%   im = AdjustImageDimensions(im, desiredParity)
%
% Inputs:
%   im - Input image.
%   desiredParity - A 2-element vector indicating the desired parity for the X and Y dimensions.
%                   Use 1 for odd and 0 for even.
%
% Outputs:
%   im - Output image with dimensions adjusted to the desired parity.

    % Validate desiredParity input
    if length(desiredParity) ~= 2 || any(desiredParity > 1) || any(desiredParity < 0)
        error('desiredParity must be a 2-element vector with values 0 (even) or 1 (odd).');
    end
    
    % Get the size of the image
    imageSize = size(im);
    imageSizeXY = imageSize(1:2); % Only consider X and Y dimensions
    
    % Calculate the current parity of the image dimensions
    currentParity = mod(imageSizeXY, 2);
    
    % Adjust dimensions based on desired parity
    for dim = 1:2
        if currentParity(dim) ~= desiredParity(dim)
            if desiredParity(dim) == 1 % Desired odd
                % If current dimension is even, remove the last row/column
                if dim == 1 % X dimension
                    im = im(1:end-1, :, :);
                else % Y dimension
                    im = im(:, 1:end-1, :);
                end
            else % Desired even
                % If current dimension is odd, add a row/column of zeros
                newSize = imageSize;
                newSize(dim) = imageSizeXY(dim) + 1;
                newIm = zeros(newSize, class(im));
                if dim == 1 % X dimension
                    newIm(1:end-1, :, :) = im;
                else % Y dimension
                    newIm(:, 1:end-1, :) = im;
                end
                im = newIm;
            end
        end
    end
end
