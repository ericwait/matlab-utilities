function orthoSliceIm = MakeOrthoSliceProjections(im, colors, physicalSize_xyz, scaleBar, projectionType, fixedDimension)
% MakeOrthoSliceProjections - Create orthogonal slice projections from 3D microscopy data.
%
% Syntax:
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, physicalSize_xyz, scaleBar)
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, physicalSize_xyz, scaleBar, projectionType)
% orthoSliceIm = ImUtils.MakeOrthoSliceProjections(im, colors, physicalSize_xyz, scaleBar, projectionType, fixedDimension)
%
% Inputs:
% im               - 3D image stack to be processed. Required.
% colors           - Color information for the image stack. Required.
% physicalSize_xyz - Physical size in the [X, Y, Z] dimensions. Required.
% scaleBar         - Scale bar to be displayed on the image. Optional.
% projectionType   - Type of projection ('max', 'min', 'mean', 'median', 'mode', 'sum'). Optional, default: 'max'.
% fixedDimension   - The dimension to be fixed (1 for X, 2 for Y, 3 for Z). Optional, default: argmin(physicalSize_xyz).
%
% Outputs:
% orthoSliceIm - Image containing orthogonal projections.
%
% Notes:
% - This function creates orthogonal projections along the XY, XZ, and YZ planes.
% - The specified dimension (X, Y, or Z) is fixed, and other dimensions are rescaled to match it.

    % Check for the optional arguments
    if ~exist("projectionType", "var") || isempty(projectionType)
        projectionType = 'max'; % Default projection type is 'max'
    end
    
    if ~exist("fixedDimension", "var") || isempty(fixedDimension)
        [~, fixedDimension] = min(physicalSize_xyz); % Default to fixing X dimension
    end
    
    % Assert valid fixedDimension
    assert(fixedDimension >= 1 && fixedDimension <= 3, 'Invalid fixedDimension. It should be 1, 2, or 3.');
    
    xRatio = physicalSize_xyz(1) / physicalSize_xyz(fixedDimension);
    yRatio = physicalSize_xyz(2) / physicalSize_xyz(fixedDimension);
    zRatio = physicalSize_xyz(3) / physicalSize_xyz(fixedDimension);
    
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
    im_xz = permute(im_xz, [3, 2, 1, 4, 5]); % zxc
    imColor_xz = ImUtils.ColorImages(squeeze(im_xz), colors);
    
    % Compute the YZ projection
    im_yz = projFunc(im, 2);
    im_yz = permute(im_yz, [1, 3, 2, 4, 5]); % yzc
    imColor_yz = ImUtils.ColorImages(squeeze(im_yz), colors);
    
    % Resize the projections to match the fixed X dimension
    imColor_xyR = imresize(imColor_xy, round(size(imColor_xy, 1:2) .* [yRatio, xRatio]));
    imColor_xzR = imresize(imColor_xz, round(size(imColor_xz, 1:2) .* [zRatio, xRatio]));
    imColor_yzR = imresize(imColor_yz, round(size(imColor_yz, 1:2) .* [yRatio, zRatio]));

    % Create an empty image for the orthogonal slices
    orthoSliceIm = im2uint8(ones(size(imColor_xyR, 1) + size(imColor_xzR, 1) + 5, size(imColor_xyR, 2) + size(imColor_yzR, 2) + 5, 3, 'single') * 0.35);
    
    % Insert the XY, XZ, and YZ images into the appropriate locations
    orthoSliceIm(1:size(imColor_xyR, 1), 1:size(imColor_xyR, 2), :) = imColor_xyR;
    orthoSliceIm(size(imColor_xyR, 1) + 6 : size(imColor_xyR, 1) + 5 + size(imColor_xzR, 1), 1:size(imColor_xyR, 2), :) = imColor_xzR;
    orthoSliceIm(1:size(imColor_xyR, 1), size(imColor_xyR, 2) + 6 : size(imColor_xyR, 2) + 5 + size(imColor_yzR, 2), :) = imColor_yzR;
    
    
    % Add the scale bar if it exists
    if exist("scaleBar", "var") && ~isempty(scaleBar)
        orthoSliceIm = ImUtils.AddScaleBarToImage(orthoSliceIm, physicalSize_xyz(fixedDimension), scaleBar, 'um', false);
    end
end
