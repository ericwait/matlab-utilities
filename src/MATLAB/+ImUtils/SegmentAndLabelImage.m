function labeledIm = SegmentAndLabelImage(im, threshs)
%SEGMENTANDLABELIMAGE Segments an image based on thresholds and labels each segment.
%
% Syntax:
%   labeledIm = SegmentAndLabelImage(im, threshs)
%
% Inputs:
%   im - A 2D or 3D grayscale image. The image to be segmented.
%   threshs - A vector of threshold values used for segmentation.
%
% Output:
%   labeledIm - A 2D or projected 2D image from 3D where each segment is labeled with a unique integer. 
%               The segments are determined based on the provided thresholds.

    % Initialize the labeled image
    labeledIm = zeros(size(im), 'uint8'); % Initialize with zeros of type uint8

    % Segment image based on thresholds and assign labels
    for i = 0:length(threshs)
        if i == 0
            % Label pixels below the first threshold with label 0
            labeledIm(im <= threshs(1)) = i;
        elseif i == length(threshs)
            % Label pixels above the last threshold with the highest label
            labeledIm(im > threshs(i)) = i;
        else
            % Label pixels between thresholds with corresponding labels
            labeledIm(im > threshs(i) & im <= threshs(i+1)) = i;
        end
    end

    % If the image is 3D, project it into 2D by taking the maximum value along the third dimension
    % This operation flattens the 3D labeled image into a 2D image by keeping the highest label encountered along the z-axis
    if ndims(im) == 3
        labeledIm = max(labeledIm, [], 3);
    end
end
