function HistogramWithThresholds(im, threshs, varargin)
%histogramWithThresholds Plots the histogram of an image and marks thresholds.
%
% Syntax:
%   histogramWithThresholds(im, threshs)
%   histogramWithThresholds(im, threshs, axHandle)
%
% Inputs:
%   im - Image data, a matrix or 3D array.
%   threshs - Vector of scalars, threshold values to be marked on the histogram.
%   axHandle (optional) - Axis handle where the histogram should be plotted.
%
% Examples:
%   histogramWithThresholds(myImage, [50, 100])
%   histogramWithThresholds(myImage, [50, 100], gca)
%
% Note: If no axis handle is provided, a new figure will be created.

    % Check if an axis handle is provided
    if ~isempty(varargin) && ishandle(varargin{1}) && strcmp(get(varargin{1}, 'Type'), 'axes')
        ax = varargin{1};
    else
        figure;
        ax = gca; % Use current axes or create a new one
    end
    
    % Plot the histogram on the specified or new axes
    histogram(ax, im, 256)
    set(ax, 'yscale', 'log');
    
    % Hold on for overlaying the threshold lines
    hold(ax, 'on');
    
    % Plot threshold lines with adjusted 'LineWidth' for thicker lines
    for i = 1:length(threshs)
        plot(ax, [threshs(i), threshs(i)], ylim(ax), 'r-', 'LineWidth', 2);
    end

    % Optionally release the hold off if you want to add more plots here
    hold(ax, 'off');
end
