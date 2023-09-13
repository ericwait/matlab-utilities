function [im_frag_iso, padded_image_size] = CreateIsometricImage(im, pixel_physical_size, padding)
    % createIsometricImage - Create an isometric version of a 3D image.
    %
    % Syntax:
    %   im_frag_iso = createIsometricImage(im, pixelPhysicalSize)
    %   im_frag_iso = createIsometricImage(im, pixelPhysicalSize, padding)
    %
    % Inputs:
    %   im              - A 3D image array.
    %   pixelPhysicalSize - A vector [row, col, z] representing the physical size 
    %                       of the voxels in the image along each dimension.
    %   padding         - (Optional) An integer defining the padding size for the image. 
    %                     Default is 0.
    %
    % Outputs:
    %   im_frag_iso     - The isometric version of the input image.
    %
    % Example:
    %   isoImage = createIsometricImage(originalImage, [1, 1, 2]);
    %   isoImage = createIsometricImage(originalImage, [1, 1, 2], 10);
    %
    % Other m-files required: ImUtils.PadImage
    %
    % Note:
    %   The function assumes that 'ImUtils.PadImage' is available in your workspace.
    
    % Set default padding to 0 if not provided
    if nargin < 3
        padding = 0;
    end

    % Compute the isometric voxel size
    iso_voxel_size = min(pixel_physical_size);

    % Compute the new dimensions for the isometric image
    new_size = round(size(im, 1:3) .* pixel_physical_size ./ iso_voxel_size) + padding * 2;

    % Pad the original image
    im_padded = ImUtils.PadImage(im, [], padding);
    padded_image_size = size(im_padded);

    % Resize the image to make it isometric
    im_frag_iso = imresize3(im_padded, new_size, 'method', 'nearest');
end
