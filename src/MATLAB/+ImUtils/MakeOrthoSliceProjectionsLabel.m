function orthoSliceIm = MakeOrthoSliceProjectionsLabel(im, colorMap, physicalSize_xyz, scaleBar, varargin)
% MakeOrthoSliceProjectionsLabel - Create orthogonal slice projections from grayscale 3D image data.
%
% Syntax:
% orthoSliceIm = MakeOrthoSliceProjectionsLabel(im, colorMap, physicalSize_xyz, scaleBar)
% orthoSliceIm = MakeOrthoSliceProjectionsLabel(im, colorMap, physicalSize_xyz, scaleBar, 'Range', [min, max])
% orthoSliceIm = MakeOrthoSliceProjectionsLabel(im, colorMap, physicalSize_xyz, scaleBar, 'Range', [min, max], 'projectionType', 'max')
% orthoSliceIm = MakeOrthoSliceProjectionsLabel(im, colorMap, physicalSize_xyz, scaleBar, 'Range', [min, max], 'projectionType', 'max', 'fixedDimension', 1)
%
% Inputs:
% im               - Grayscale 3D image stack to be processed. Required.
% colorMap         - Colormap for the image. Mx3 matrix. Required.
% physicalSize_xyz - Physical size in the [X, Y, Z] dimensions. Required.
% scaleBar         - Scale bar to be displayed on the image. Optional.
% Range            - Optional range for histogram [min, max]. Default: [-inf, inf].
% projectionType   - Type of projection ('max', 'min', 'mean', 'median', 'mode', 'sum'). Optional, default: 'max'.
% fixedDimension   - The dimension to be fixed (1 for X, 2 for Y, 3 for Z). Optional, default: argmin(physicalSize_xyz).
%
% Outputs:
% orthoSliceIm - Image containing orthogonal projections with RGB components.
%
% Notes:
% - This function creates orthogonal projections along the XY, XZ, and YZ planes.
% - The specified dimension (X, Y, or Z) is fixed, and other dimensions are rescaled to match it.
% - The colormap must be an explicit matrix.

    [~, defaultFixedDimension] = min(physicalSize_xyz);

    % Parse optional input arguments
    p = inputParser;
    addParameter(p, 'Range', [-inf, inf], @(x) isnumeric(x) && numel(x) == 2);
    addParameter(p, 'projectionType', 'max', @(x) ischar(x) || isstring(x));
    addParameter(p, 'fixedDimension', defaultFixedDimension);
    parse(p, varargin{:});
    range = p.Results.Range;
    projectionType = p.Results.projectionType;
    fixedDimension = p.Results.fixedDimension;

    % Validate the colormap
    assert(size(colorMap, 2) == 3, 'ColorMap must be an Mx3 matrix.');

    if range(1) == -inf
        range(1) = min(im(:));
    end
    if range(2) == inf
        range(2) = max(im(:));
    end
    
    % Clip the image values based on the range
    imClipped = max(min(im, range(2)), range(1));

    % Calculate the histogram and map the values to colors
    numColors = size(colorMap, 1);
    bins = linspace(range(1), range(2), numColors + 1);
    [~, ~, binIndices] = histcounts(imClipped, bins);
    
    % Initialize a 4D image (X, Y, Z, RGB)
    imRGB = zeros([numel(im), 3], 'like', im);
    
    % Apply the colormap
    for binInd = 2:length(bins)
        imMask = binIndices(:) == binInd;
        if any(imMask(:))
            imRGB(imMask, :) = repmat(colorMap(binInd, :), [nnz(imMask), 1]);
        end
    end
    imRGB = reshape(imRGB, [size(im), 3]);

    % Call the MakeOrthoSliceProjections function
    orthoSliceIm = ImUtils.MakeOrthoSliceProjections(imRGB, [1,0,0;0,1,0;0,0,1], physicalSize_xyz, scaleBar, projectionType, fixedDimension);
end
