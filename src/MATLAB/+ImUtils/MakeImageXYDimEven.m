function im = MakeImageXYDimEven(im)
%MAKEIMAGEXYDIMEVEN Adjusts the X and Y dimensions of an image to be even.
%
% Warning:
%   This function is deprecated and will not be supported in future versions.
%   Use AdjustImageDimensions instead with desiredParity set to [0 0] for even dimensions.
%
% Syntax:
%   im = MakeImageXYDimEven(im)
%
% Inputs:
%   im - Input image.
%
% Outputs:
%   im - Output image with X and Y dimensions adjusted to be even.
%
% See also ADJUSTIMAGEDIMENSIONS

    % Display deprecation warning
    warning('MakeImageXYDimEven is deprecated and will be removed in future versions. Use AdjustImageDimensions(im, [0 0]) instead.');

    sizeEven = size(im)/2;
    sizeEven = sizeEven([1,2]);
    sizeEven = sizeEven~=round(sizeEven);
    if (any(sizeEven))
        im(end:end+sizeEven(1),end:end+sizeEven(2),:) = 0;
    end
end
