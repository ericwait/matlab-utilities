function [im_hematoxylin_final, im_eosin_final, im_residual_final] = HaEColorDeconvolution(image_rgb, vector_hematoxylin, vector_eosin, vector_residual, displayResults)
% HaEColorDeconvolution - Color deconvolution for H&E stained images.
%
% Syntax:
% [im_hematoxylin_final, im_eosin_final, im_residual_final] = Unmix.HaEColorDeconvolution(image_rgb)
% [im_hematoxylin_final, im_eosin_final, im_residual_final] = Unmix.HaEColorDeconvolution(image_rgb, vector_hematoxylin, vector_eosin, vector_residual, displayResults)
%
% Inputs:
% image_rgb         - RGB image to be processed. Required.
% vector_hematoxylin - 3x1 vector specifying Hematoxylin color space. Optional, default: [0.63401; 0.72504; 0.26897].
% vector_eosin      - 3x1 vector specifying Eosin color space. Optional, default: [0.28808; 0.84773; 0.44538].
% vector_residual   - 3x1 vector specifying the Residual color space. Optional, default: [0.238; -0.514; 0.824].
% displayResults    - Boolean, whether to display the separated channels. Optional, default: false.
%
% Outputs:
% im_hematoxylin_final - Image containing only the Hematoxylin channel.
% im_eosin_final       - Image containing only the Eosin channel.
% im_residual_final    - Image containing only the Residual channel.
%
% Example:
% img = imread('sample.jpg');
% [hematoxylin, eosin, residual] = Unmix.HaEColorDeconvolution(img);
% [hematoxylin, eosin, residual] = Unmix.HaEColorDeconvolution(img, [], [], [], true);
%
% Notes:
% - The function uses a least squares method to separate the color channels.
% - Vectors for hematoxylin, eosin, and residual should be normalized before using (this function will normalize them if they are not).
%

    % Check for the optional arguments
    if nargin < 2 || isempty(vector_hematoxylin)
        vector_hematoxylin = [0.63401; 0.72504; 0.26897]; % Default Hematoxylin
    end
    if nargin < 3 || isempty(vector_eosin)
        vector_eosin = [0.28808; 0.84773; 0.44538]; % Default Eosin
    end
    if nargin < 4 || isempty(vector_residual)
        vector_residual = [0.238; -0.514; 0.824]; % Default Residual
    end
    if nargin < 5 || isempty(displayResults)
        displayResults = false; % Default is not to display results
    end
    
    % Convert to double precision for computation
    image_rgb_norm = ImUtils.ConvertType(image_rgb, 'double', false);
    
    % Normalize stains to unit vector
    vector_hematoxylin = vector_hematoxylin / norm(vector_hematoxylin);
    vector_eosin = vector_eosin / norm(vector_eosin);
    vector_residual = vector_residual / norm(vector_residual);
    
    % Create stain matrix
    stain_matrix = [vector_hematoxylin, vector_eosin, vector_residual];
    
    % Reshape and normalize the image
    [num_rows, num_cols, ~] = size(image_rgb);
    image_rgb_col = reshape(image_rgb_norm, [], 3);
    
    % Perform color deconvolution
    stain_amounts = stain_matrix \ image_rgb_col';  % Linear least squares
    
    % Extract channels
    im_hematoxylin = stain_amounts(1, :);
    im_eosin = stain_amounts(2, :);
    % im_residual = stain_amounts(3, :);
    
    % Invert and remove background
    im_hematoxylin_bright = (1 - im_hematoxylin);% - 0.8;
    im_hematoxylin_bright(im_hematoxylin_bright(:) < 0) = 0;
    
    im_eosin_bright = (1 - im_eosin);% - 0.8;
    im_eosin_bright(im_eosin_bright(:) < 0) = 0;
    
    im_residual_bright = (im_hematoxylin_bright + im_eosin_bright);% - 0.8;
    im_residual_bright(im_residual_bright(:) < 0) = 0;
    
    % Reshape to original image dimensions
    im_hematoxylin_final = reshape(im_hematoxylin_bright, num_rows, num_cols);
    im_eosin_final = reshape(im_eosin_bright, num_rows, num_cols);
    im_residual_final = reshape(im_residual_bright, num_rows, num_cols);

    im_hematoxylin_final = ImUtils.ConvertType(im_hematoxylin_final, 'uint16', false);
    im_eosin_final = ImUtils.ConvertType(im_eosin_final, 'uint16', false);
    im_residual_final = ImUtils.ConvertType(im_residual_final, 'uint16', false);
    
    % Optionally display the separated channels
    if displayResults
        figure;
        subplot(1, 4, 1), imshow(image_rgb, []), title('Original RGB');
        subplot(1, 4, 2), imshow(im_hematoxylin_final, []), title('Hematoxylin');
        subplot(1, 4, 3), imshow(im_eosin_final, []), title('Eosin');
        subplot(1, 4, 4), imshow(im_residual_final, []), title('Residual');
    end
end
