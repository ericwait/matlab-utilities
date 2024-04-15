function imLabel = SplitByAreaPixelRep(im_mask, maxArea, maxSplitNumber, progress)
% Splits large connected components in a binary mask into smaller regions.
%
% This function processes a binary mask image, identifying connected components
% and splitting those larger than a specified maximum area into smaller segments.
% Each segment is assigned a unique label in the output labeled image. The function
% can optionally limit the number of splits performed and display progress.
%
% Usage:
%   imLabel = SplitByAreaPixelRep(im_mask, maxArea, maxSplitNumber, progress)
%
% Inputs:
%   im_mask - A binary image mask where the connected components to be split are marked as true (1).
%   maxArea - The maximum area (in pixels) allowed for a connected component. Components larger than this
%             will be split into smaller regions.
%   maxSplitNumber - (Optional) The maximum number of segments a single component can be split into. 
%                    Defaults to 21 if not specified.
%   progress - (Optional) A boolean indicating whether to display progress information. 
%              Defaults to false if not specified.
%
% Outputs:
%   imLabel - A labeled image of the same size as im_mask. Each connected component or segment
%             is assigned a unique label (starting from 1). Components smaller than maxArea retain
%             their original connectivity, while larger ones are split according to the algorithm.
%
% Example:
%   imLabel = SplitByAreaPixelRep(binaryMask, 500, 30, true);
%   This will split connected components in binaryMask larger than 500 pixels into segments,
%   with no more than 30 segments for a single component, and display the progress.

    % Set default parameters if not provided
    if nargin < 3
        maxSplitNumber = 21; % Default maximum number of splits
    end
    if nargin < 4
        progress = false; % Default progress display setting
    end

    % Initialize variables
    sizes = size(im_mask, 1:2); % Get the size of the mask
    rp = regionprops(im_mask, 'PixelIdxList', 'Area'); % Get properties of connected components
    imLabel = zeros(size(im_mask), 'uint16'); % Initialize labeled image
    curLabel = 0; % Current label counter

    % Early exit if there are no regions to process
    if isempty(rp)
        return
    end

    % Optionally initialize progress display
    if progress
        prgs = Utils.CmdlnProgress(length(rp), false, 'Splitting cells');
    end

    % Process each connected component
    for rpInd = 1:length(rp)
        curRp = rp(rpInd); % Current region properties
        
        % Calculate expected number of cells based on the area
        nExpectedCells = ceil(curRp.Area / maxArea);
        
        % Assign current label if splitting is not required or exceeds limit
        if nExpectedCells < 2 || nExpectedCells > maxSplitNumber
            curLabel = curLabel + 1;
            imLabel(curRp.PixelIdxList) = curLabel;
            continue; % Skip further processing for this component
        end
        
        % Split component if within the allowable range
        labelInd = Segmentation.SplitByPixelRep(sizes, curRp.PixelIdxList, nExpectedCells);
        labelInd = labelInd + curLabel; % Adjust labels to continue numbering

        % Update the labeled image and current label counter
        imLabel(curRp.PixelIdxList) = labelInd;
        curLabel = max(labelInd); % Update label counter

        % Optionally update progress
        if progress
            prgs.PrintProgress(rpInd);
        end
    end

    % Optionally clear progress display
    if progress
        prgs.ClearProgress(true);
    end
end
