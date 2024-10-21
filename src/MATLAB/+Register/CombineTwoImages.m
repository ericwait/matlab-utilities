function [im,meta] = CombineTwoImages(im1,im1Data,im2,im2Data,deltas,unitFactor,visualize)
    % CombineTwoImages Combines two images by overlapping them based on their
    % respective ROI (Region of Interest) and delta shifts.
    %
    % Inputs:
    %   - im1: The first image (multi-dimensional matrix)
    %   - im1Data: Metadata for the first image containing dimensions and physical size
    %   - im2: The second image (multi-dimensional matrix)
    %   - im2Data: Metadata for the second image containing dimensions and physical size
    %   - deltas: A vector [dx, dy, dz] indicating the shift between the images (optional)
    %   - unitFactor: A scaling factor for the units (optional)
    %   - visualize: A boolean flag to indicate if the result should be visualized (optional)
    %
    % Outputs:
    %   - im: The combined image
    %   - meta: Metadata for the combined image
    
    % Set default values for optional inputs
    if (~exist('deltas','var') || isempty(deltas))
        deltas = [0,0,0];
    end
    if (~exist('unitFactor','var'))
        unitFactor = [];
    end
    
    % Calculate the overlap regions for the two images in XY plane
    [im1ROI,im2ROI,~,~] = Register.CalculateOverlapXY(im1Data,im2Data,unitFactor);
    
    % Check if there is any overlap; if not, throw an error
    if (any(im1ROI(4:6) - im1ROI(1:3) == 0)) || (any(im2ROI(4:6) - im2ROI(1:3) == 0))
        error('There is no overlap');
    end
    
    % Initialize start and end indices for both images
    im1Starts = [1,1,1];
    im1Ends = [size(im1,2),size(im1,1),size(im1,3)];
    im2Starts = [1,1,1];
    im2Ends = [size(im2,2),size(im2,1),size(im2,3)];
    
    % Loop over each dimension (x, y, z)
    for i = 1:3
        if (im1ROI(i)==1 && im2ROI(i)==1)
            % If both images are aligned in this dimension
            if (sign(deltas(i))>=0)
                % Positive shift: move the second image forward
                im1Starts(i) = 1;
                im2Starts(i) = deltas(i) + 1;
            else
                % Negative shift: move the first image forward
                im1Starts(i) = max(1, abs(deltas(i)) + 1);
                im2Starts(i) = 1;
            end
        elseif (im1ROI(i)>1)
            % If the second image is ahead in the positive direction
            if (sign(deltas(i))>=0)
                % Positive shift: move the second image further forward
                im1Starts(i) = 1;
                im2Starts(i) = im1ROI(i) + deltas(i) + 1;
            else
                % Negative shift: adjust the first image position
                if (abs(deltas(i)) > im1ROI(i))
                    % Shift would push the second image behind the first
                    leftShift = im1ROI(i) + deltas(i); % Adjust for negative shift
                    im1Starts(i) = max(1, leftShift + 1);
                    im2Starts(i) = 1;
                else
                    % Shift is not enough to change the order
                    im1Starts(i) = 1;
                    im2Starts(i) = im1ROI(i) + deltas(i);
                end
            end
        else
            % If the second image is behind in the negative direction
            if (sign(deltas(i))>=0)
                % Positive shift: move the second image forward
                if (deltas(i) > im2ROI(i))
                    % Shift would push the second image ahead of the first
                    rightShift = im2ROI(i) - deltas(i); % Adjust for positive shift
                    im1Starts(i) = 1;
                    im2Starts(i) = max(1, rightShift + 1);
                else
                    % Shift is not enough to change the order
                    im1Starts(i) = im2ROI(i) - deltas(i);
                    im2Starts(i) = 1;
                end
            else
                % Negative shift: move the first image forward
                im1Starts(i) = im2ROI(i) - deltas(i); % Adjust for negative shift
                im2Starts(i) = 1;
            end
        end
        
        % Calculate the end indices based on the new start indices
        im1Ends(i) = im1Starts(i) + im1Ends(i) - 1;
        im2Ends(i) = im2Starts(i) + im2Ends(i) - 1;
    end
    
    % Determine the size of the combined image
    combinedWidth = abs(im1ROI(1)-im2ROI(1)) + max(size(im1,2),size(im2,2));
    combinedHeight = abs(im1ROI(2)-im2ROI(2)) + max(size(im1,1),size(im2,1));
    combinedDepth = abs(im1ROI(3)-im2ROI(3)) + max(size(im1,3),size(im2,3));
    
    % Initialize the combined image with zeros
    im = zeros(combinedHeight, combinedWidth, combinedDepth, size(im1,4) + size(im2,4), 'like', im1);
    
    % Place the first image into the combined image
    im(im1Starts(2):im1Ends(2), im1Starts(1):im1Ends(1), im1Starts(3):im1Ends(3), 1:size(im1,4)) = im1;
    
    % Place the second image into the combined image
    im(im2Starts(2):im2Ends(2), im2Starts(1):im2Ends(1), im2Starts(3):im2Ends(3), size(im1,4) + 1:size(im1,4) + size(im2,4)) = im2;

    % Remove planes that contain all zeros before assigning metadata
    % Check for all-zero planes in XY (along Z-axis)
    nonZeroZPlanes = squeeze(any(any(any(im, 1), 2), 4));
    im = im(:, :, nonZeroZPlanes, :);

    % Check for all-zero planes in XZ (along Y-axis)
    nonZeroYPlanes = squeeze(any(any(any(im, 3), 2), 4));
    im = im(nonZeroYPlanes, :, :, :);

    % Check for all-zero planes in YZ (along X-axis)
    nonZeroXPlanes =  squeeze(any(any(any(im, 3), 1), 4));
    im = im(:, nonZeroXPlanes, :, :);
    
    % Update metadata for the combined image
    meta = im1Data;
    meta.Dimensions = size(im,[2,1,3]);
    meta.NumberOfChannels = size(im,4);
    meta.ChannelNames = {meta.ChannelNames; im2Data.ChannelNames};
    meta.ChannelColors = [meta.ChannelColors; im2Data.ChannelColors];
    
    % If visualization is enabled, create and display an orthogonal slice projection
    if visualize
        colors = parula(size(im, 4)+1);
        imOrtho = ImUtils.MakeOrthoSliceProjections(im, colors(2:end,:), meta.PixelPhysicalSize, 50);
        figure;
        imshow(imOrtho);
    end
end
