function rgbImage = ColorizeGrayscaleImage(grayscaleImage, color)
    %COLORIZEGRAYSCALEIMAGE Colorizes a grayscale image with a specified RGB color.
    %
    % Syntax:
    % rgbImage = colorizeGrayscaleImage(grayscaleImage, color)
    %
    % Description:
    % This function takes a grayscale image and a color vector, then produces
    % an RGB image by applying the specified color to the grayscale image. This
    % colorization process maintains the intensity variations of the original
    % image while overlaying it with the specified color.
    %
    % Inputs:
    % grayscaleImage - A 2D array representing the grayscale image. It should
    % be of type double, uint8, or uint16. The function will normalize the image
    % to the [0, 1] range for processing.
    %
    % color - A 1x3 RGB vector where each component is in the [0, 1] range.
    % This vector specifies the color to apply to the grayscale image. Each
    % element of the vector corresponds to the Red, Green, and Blue components
    % of the color, respectively.
    %
    % Outputs:
    % rgbImage - A 3D array representing the colorized RGB image. The output
    % image has the same height and width as the input grayscale image, with
    % three channels corresponding to the RGB components. The pixel values are
    % in the [0, 1] range, suitable for display with MATLAB's image display
    % functions.
    %
    % Example:
    % img = imread('path/to/your/grayscale/image.jpg');
    % color = [1, 0.5, 0]; % Orange color
    % colorizedImg = colorizeGrayscaleImage(img, color);
    % imshow(colorizedImg);


    % Ensure the grayscale image is in the range [0, 1]
    if ~ismatrix(grayscaleImage)
        error('Currently colorization only works on 2D images.');
    end

    grayscaleImage = ImUtils.ConvertType(grayscaleImage, 'single', true);
    grayscaleImage = grayscaleImage / max(grayscaleImage(:));
    
    % Preallocate the RGB image
    rgbImage = zeros([size(grayscaleImage), 3]);
    
    % Apply the color to each channel of the grayscale image
    for channel = 1:3
        rgbImage(:,:,channel) = grayscaleImage * color(channel);
    end
    
    % Ensure the output is in the appropriate range [0, 1]
    rgbImage = max(min(rgbImage, 1), 0);
end
