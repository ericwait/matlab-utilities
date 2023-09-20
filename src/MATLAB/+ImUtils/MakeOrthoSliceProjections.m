function orthoSliceIm = MakeOrthoSliceProjections(im, colors, physicalSize_xyz, scaleBar, projectionType)
% MakeOrthoSliceProjections - Create orthogonal slice projections from 3D microscopy data.
%
% Syntax:
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, xyPhysicalSize, zPhysicalSize, scaleBar)
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, xyPhysicalSize, zPhysicalSize, scaleBar, projectionType)
%
% Inputs:
% im           - 3D image stack to be processed. Required.
% colors       - Color information for the image stack. Required.
% xyPhysicalSize - Physical size in the XY plane. Required.
% zPhysicalSize  - Physical size in the Z direction. Required.
% scaleBar     - Scale bar to be displayed on the image. Optional.
% projectionType - Type of projection ('max', 'min', 'mean', 'median', 'mode', 'sum'). Optional, default: 'max'.
%
% Outputs:
% orthoSliceIm - Image containing orthogonal projections.
%
% Example:
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, 0.5, 1)
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, 0.5, 1, 50, 'mean')
%
% Notes:
% - This function creates orthogonal projections along the XY, XZ, and YZ planes.

    % Check for the optional arguments
    if nargin < 6
        projectionType = 'max'; % Default projection type is 'max'
    end
    
    xPhysicalSize = physicalSize_xyz(1);
    yPhysicalSize = physicalSize_xyz(2);
    zPhysicalSize = physicalSize_xyz(3);
    
    zRatioX = zPhysicalSize / xPhysicalSize;
    zRatioY = zPhysicalSize / yPhysicalSize;
    
    % Determine the type of projection to perform
    switch lower(projectionType)
        case 'max'
            projFunc = @(x, dim) max(x, [], dim);
        case 'min'
            projFunc = @(x, dim) min(x, [], dim);
        case 'mean'
            projFunc = @(x, dim) mean(x, dim);
        case 'median'
            projFunc = @(x, dim) median(x, dim);
        case 'sum'
            projFunc = @(x, dim) sum(x, dim);
        case 'mode'
            projFunc = @(x, dim) mode(x, dim);
        case 'std'
            projFunc = @(x, dim) std(single(x), [], dim);
        otherwise
            error('Invalid projectionType. Valid options are "max", "min", "mean", "median", "mode", "std", "sum".');
    end

    % Compute the XY projection
    imColor_xy = ImUtils.ColorImages(squeeze(projFunc(im, 3)), colors);

    % Compute the XZ projection
    im_xz = projFunc(im, 1);
    im_xz = permute(im_xz, [3, 2, 4, 1]);
    imColor_xz = ImUtils.ColorImages(im_xz, colors);
    
    % Compute the YZ projection
    im_yz = projFunc(im, 2);
    im_yz = permute(im_yz, [1, 3, 4, 2]);
    imColor_yz = ImUtils.ColorImages(im_yz, colors);
    
    % Resize the XZ and YZ projections
    imColor_xzR = imresize(imColor_xz, [round(size(imColor_xz, 1) * zRatioX), size(imColor_xz, 2)]);
    imColor_yzR = imresize(imColor_yz, [size(imColor_yz, 1), round(size(imColor_yz, 2) * zRatioY)]);

    % Create an empty image for the orthogonal slices
    orthoSliceIm = im2uint8(ones(size(imColor_xy, 1) + size(imColor_xzR, 1) + 5, size(imColor_xy, 2) + size(imColor_yzR, 2) + 5, 3, 'single') * 0.35);
    
    % Insert the XY, XZ, and YZ images into the appropriate locations
    orthoSliceIm(1:size(imColor_xy, 1), 1:size(imColor_xy, 2), :) = imColor_xy;
    orthoSliceIm(size(imColor_xy, 1) + 6 : size(imColor_xy, 1) + 5 + size(imColor_xzR, 1), 1:size(imColor_xy, 2), :) = imColor_xzR;
    orthoSliceIm(1:size(imColor_xy, 1), size(imColor_xy, 2) + 6 : size(imColor_xy, 2) + 5 + size(imColor_yzR, 2), :) = imColor_yzR;
    
    % Add the scale bar if it exists
    if exist("scaleBar", "var") && ~isempty(scaleBar)
        scaleBarLength = round(scaleBar / xPhysicalSize);
        orthoSliceIm(end - 40 : end - 20, end - 20 - scaleBarLength + 1 : end - 20, :) = 255;
    end
end
