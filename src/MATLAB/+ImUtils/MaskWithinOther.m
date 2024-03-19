function imBWcombined = MaskWithinOther(imMask, imMaskOther)
% MaskWithinOther filters a mask based on overlap with another mask.
%
% This function identifies connected components in the first input mask
% and retains only those components that have at least one pixel marked as true
% in the second input mask. The result is a new mask containing only the
% overlapping components.
%
% Usage:
%   imBWcombined = MaskWithinOther(imMask, imMaskOther)
%
% Inputs:
%   imMask - A logical matrix representing the initial mask, where connected
%            components are identified for potential inclusion in the output.
%            This mask defines the set of regions to be tested for overlap
%            with the second mask.
%   imMaskOther - A logical matrix of the same size as imMask, indicating pixels
%              of interest. Connected components in imMask that have at least
%              one overlapping pixel with imMaskOther set to true are retained
%              in the output mask.
%
% Outputs:
%   imBWcombined - A logical matrix of the same size as imMask and imMaskOther,
%                  containing only those connected components from imMask
%                  that overlap with the true pixels in imMaskOther.
%
% Example:
%   % Create an example mask with two separate components
%   imMask = false(10,10);
%   imMask(2:4, 2:4) = true; % First component
%   imMask(7:9, 7:9) = true; % Second component
%
%   % Create a mask indicating pixels of interest
%   imMaskOther = false(10,10);
%   imMaskOther(3,3) = true; % Overlaps with the first component only
%
%   % Filter the mask to retain components overlapping with imMaskOther
%   imBWcombined = MaskWithinOther(imMask, imMaskOther);
%
%   % imBWcombined will now contain only the first component from imMask
%
% Note:
%   The function uses the 'regionprops' function with 'PixelIdxList' and
%   'MaxIntensity' properties to identify relevant components. It is assumed
%   that imMask and imMaskOther are logical matrices of the same size.

    % Calculate properties of labeled regions in imMask with respect to imMaskOther.
    rp = regionprops(imMask, imMaskOther, 'PixelIdxList', 'MaxIntensity');
    
    % Initialize an output image of the same size as imMask, filled with false.
    imBWcombined = false(size(imMask));
    
    % Iterate through each region defined in imMask.
    for rpInd = 1:length(rp)
        % Check if the region has any true pixel in imMaskOther (MaxIntensity != 0).
        if rp(rpInd).MaxIntensity ~= 0
            % Mark all pixels of this region as true in the output image.
            imBWcombined(rp(rpInd).PixelIdxList) = true;
        end
    end
    % Return the combined mask.
end
