function im = AdjustImageDimensions(im, desiredParity)
%ADJUSTIMAGEDIMENSIONS Adjusts the dimensions of an image to be odd or even by padding.
%
% This function ensures the dimensions of an image meet the desired parity (odd or even)
% by padding the image. It will not crop the image.
%
% Syntax:
%   im = AdjustImageDimensions(im, desiredParity)
%
% Inputs:
%   im - Input image.
%   desiredParity - A 2-element vector indicating the desired parity for the height and width.
%                   Use [1 1] for odd dimensions and [0 0] for even dimensions.
%
% Outputs:
%   im - Output image with adjusted dimensions.
%
% Example:
%   imAdjusted = AdjustImageDimensions(im, [0 0]); % Adjust for even dimensions
%   imAdjusted = AdjustImageDimensions(im, [1 1]); % Adjust for odd dimensions

    % Validate input
    if numel(desiredParity) ~= 2 || any(~ismember(desiredParity, [0, 1]))
        error('desiredParity must be a 2-element vector with values 0 (even) or 1 (odd)');
    end

    imageSize = size(im);
    currentParity = mod(imageSize(1:2), 2); % Current parity of the image dimensions
    parityDifference = desiredParity - currentParity;
    
    % Adjust dimensions to match desired parity by padding
    padSize = [0 0]; % Initialize padding size
    for dim = 1:2
        if parityDifference(dim) ~= 0
            padSize(dim) = 1; % Add padding if necessary to change parity
        end
    end

    % Apply padding if needed
    if any(padSize > 0)
        padValue = 0; % Define pad value, adjust as necessary for different image types
        im = padarray(im, padSize, padValue, 'post');
    end
end
