function ImShowPairWBinary(imGray, imBW, gamma, bwBias, axisHandle)
% ImShowPairWBinary overlays a grayscale image with a binary mask using imshowpair.
%
%   imGray     - Grayscale image
%   imBW       - Binary mask
%   gamma      - Gamma correction for grayscale image
%   bwBias     - Intensity multiplier for binary image
%   axisHandle - (optional) Axes handle to display the image. If not provided, a new figure is created.

    arguments
        imGray
        imBW
        gamma double = 1
        bwBias double = 1
        axisHandle = []
    end

    % Ensure axis exists or create one
    if isempty(axisHandle) || ~isvalid(axisHandle)
        fig = figure;
        axisHandle = axes('Parent', fig);
    end

    % Prepare images
    grayImg = ImUtils.BrightenImagesGamma(imGray, 'single', gamma);
    bwImg   = im2single(imBW) * bwBias;

    % Show overlay
    imshowpair(grayImg, bwImg, 'scaling', 'none', 'Parent', axisHandle);
end
