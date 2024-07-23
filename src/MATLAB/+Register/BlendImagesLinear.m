function blendedImage = BlendImagesLinear(inputImage, numChannels)
    % BLENDIMAGES Blends overlapping images using weighted sum blending with proper normalization.
    %
    % blendedImage = blendImages(inputImage, numChannels)
    % blends the images in the input 4D array using weighted sum blending.
    % The function assumes the input images have some overlap and blends them
    % such that the intensity weights are inversely proportional to the distance
    % from the edge of the image, with proper normalization.
    %
    % Input:
    %   inputImage  - A 4D array of size [x, y, z, totalChannels], where the first
    %                 three dimensions are spatial and the fourth dimension contains
    %                 the different channels.
    %   numChannels - The number of channels per image.
    %
    % Output:
    %   blendedImage - A 4D array of size [x, y, z, numChannels] containing the
    %                  blended images.

    % Get the size of the input image
    [x, y, z, totalChannels] = size(inputImage);

    % Determine the number of images
    numImages = totalChannels / numChannels;

    imSplit = zeros([size(inputImage,1:3), numChannels, size(inputImage,5), numImages], 'like', inputImage);
    for img = 1:numImages
        for ch = 1:numChannels
            chanInd = (img - 1) * numChannels + ch;
            imSplit(:, :, :, ch , :, img) = inputImage(:, :, :, chanInd, :);
        end
    end

    masks = max(imSplit, [], 3:4) > 0;
    distanceMaps = zeros(size(masks));
    for img = 1:numImages
        for timeInd = 1:size(imSplit, 5)
            % because of the max across z and c, the 3rd and 4th index will always be 1.
            distanceMaps(:,:,1,1,timeInd, img) = bwdist(~masks(:,:,1,1,timeInd, img));
        end
    end

    blendedImage = zeros([size(inputImage,1:3), numChannels, size(inputImage,5)], 'single');
    % figure
    for img = 1:numImages
        % nexttile
        curMask = max(blendedImage>0, [], 3:4);
        incomingMask = masks(:, :, 1, 1, :, img);
        placeMask = repmat(incomingMask & ~curMask, [1,1,size(inputImage,3), numChannels, 1]);

        % put pixels down that don't need blending
        incomingIm = imSplit(:, :, :, :, :, img);
        blendedImage(placeMask) = incomingIm(placeMask);
        % imshow(squeeze(max(blendedImage, [], 3:5)))

        % blend the overlap based on distance from rest of image
        overlapMask = curMask & incomingMask;
        curDist = bwdist(~curMask & ~overlapMask);
        incomingDist = bwdist(~incomingMask & ~overlapMask);

        curSum = curDist + incomingDist;
        curSum(~overlapMask) = 0;

        curMul = zeros(size(curMask), 'single');
        curMul(overlapMask(:)) = curDist(overlapMask(:)) ./ curSum(overlapMask(:));

        incomingMul = zeros(size(curMask));
        incomingMul(overlapMask(:)) = incomingDist(overlapMask(:)) ./ curSum(overlapMask(:));

        overlapMask = repmat(overlapMask, [1, 1, size(blendedImage,3:5)]);
        curMul = repmat(curMul, [1, 1, size(blendedImage,3:5)]);
        incomingMul = repmat(incomingMul, [1, 1, size(blendedImage,3:5)]);

        blendedImage(overlapMask(:)) = single(blendedImage(overlapMask(:))) .* curMul(overlapMask(:)) + single(incomingIm(overlapMask(:))) .* incomingMul(overlapMask(:));
        % nexttile
        % imshow(squeeze(max(blendedImage, [], 3:5)))
    end
end
