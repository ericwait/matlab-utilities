function VisualizeMultithresh(im, threshs)
%COMBINEDVISUALIZATION Creates a combined visualization of image histogram with thresholds
% and the resulting segmented, colored image.
%
% Syntax:
%   combinedVisualization(im, threshs)
%
% Inputs:
%   im - A 2D or 3D grayscale image.
%   threshs - A vector of threshold values used for segmentation.

    % Create a new figure and layout for 2 subplots
    figure;
    t = tiledlayout(1, 2); % 1 row, 2 columns

    % Plot histogram with thresholds in the first tile
    ax1 = nexttile(t);
    ImUtils.HistogramWithThresholds(im, threshs, ax1);

    % Segment, color, and display the image in the second tile
    ax2 = nexttile(t);
    colorSegmentedImage = ImUtils.SegmentAndLabelImage(im, threshs);
    imagesc(colorSegmentedImage, 'Parent', ax2);
    axis image
    colormap([0,0,0; parula(max(colorSegmentedImage(:)))]);
    colorbar
    title(ax2, sprintf('Segmented and Colored Image Using %d Thresholds', length(threshs)));
end