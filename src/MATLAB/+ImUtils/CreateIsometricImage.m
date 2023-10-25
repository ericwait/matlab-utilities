function [im_iso, original_image_size, target_voxel_size] = CreateIsometricImage(im, pixel_physical_size, target_voxel_size, resize_method)
    % CreateIsometricImage - Create an isometric version of a 2D or 3D image.
    %
    % Syntax:
    %   [im_iso, original_image_size] = CreateIsometricImage(im, pixel_physical_size)
    %   [im_iso, original_image_size] = CreateIsometricImage(im, pixel_physical_size, target_voxel_size, resize_method)
    %
    % Inputs:
    %   im                  - A 2D or 3D image array.
    %   pixel_physical_size - A vector [row, col, (z)] representing the physical size 
    %                         of the pixels/voxels in the image along each dimension.
    %   target_voxel_size   - (Optional) The desired pixel/voxel size for the isotropic image. 
    %                         Default is the minimum pixel/voxel size.
    %   resize_method       - (Optional) Method used for resizing. Default is 'nearest'.
    %
    % Outputs:
    %   im_iso              - The isometric version of the input image.
    %   original_image_size - The size of the original image.
    %
    % Example for 3D image:
    %   [iso_image, orig_size] = CreateIsometricImage(original_image, [1, 1, 2]);
    %   [iso_image, orig_size] = CreateIsometricImage(original_image, [1, 1, 2], 0.5, 'cubic');
    %
    % Example for 2D image:
    %   [iso_image, orig_size] = CreateIsometricImage(original_image, [1, 1]);
    %   [iso_image, orig_size] = CreateIsometricImage(original_image, [1, 1], 0.5, 'cubic');
    %
    % Note:
    %   The function assumes that 'ImUtils.PadImage' is not required for this version.

    % Determine if the image is 2D or 3D
    is_3D = ndims(im) == 3;

    % Set default values if not provided
    if nargin < 3 || isempty(target_voxel_size)
        target_voxel_size = min(pixel_physical_size);
    end
    
    if nargin < 4 || isempty(resize_method)
        resize_method = 'nearest';
    end
    
    % Store the original image size for return
    original_image_size = size(im);

    % Compute the new dimensions for the isometric image
    if is_3D
        new_size = round(size(im, 1:3) .* pixel_physical_size ./ target_voxel_size);
        % Resize the image to make it isometric
        im_iso = imresize3(im, new_size, 'method', resize_method);
    else
        new_size = round(size(im, 1:2) .* pixel_physical_size(1:2) ./ target_voxel_size);
        % Resize the image to make it isometric
        im_iso = imresize(im, new_size, 'method', resize_method);
    end
end
