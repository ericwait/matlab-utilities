function blendedImage = BlendImagesGradient(inputImage, numChannels)
    % BLENDIMAGESGRADIENTDOMAIN Blends overlapping images using gradient domain blending.
    %
    % blendedImage = blendImagesGradientDomain(inputImage, numChannels)
    % blends the images in the input 4D array using gradient domain blending.
    % The function assumes the input images have some overlap and blends them
    % to ensure smooth transitions in the gradients.
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

    % Initialize the blended image with two channels
    blendedImage = zeros(x, y, z, numChannels);

    % Iterate over each channel to blend
    for ch = 1:numChannels
        % Extract relevant channels
        relevantChannels = inputImage(:, :, :, ch:numChannels:end);

        % Initialize blended gradients
        blendedGradX = zeros(x, y, z);
        blendedGradY = zeros(x, y, z);

        % Compute and blend gradients for each image
        for img = 1:numImages
            currentChannel = relevantChannels(:, :, :, img);
            mask = currentChannel > 0;
            [gradX, gradY] = gradient(currentChannel);

            blendedGradX = blendedGradX + gradX .* mask;
            blendedGradY = blendedGradY + gradY .* mask;
        end

        % Normalize blended gradients by the number of images
        blendedGradX = blendedGradX / numImages;
        blendedGradY = blendedGradY / numImages;

        % Initialize the blended image with the first image of the current channel
        blendedImage(:, :, :, ch) = relevantChannels(:, :, :, 1);

        % Solve the Poisson equation to reconstruct the blended image for the current channel
        blendedImage(:, :, :, ch) = poissonSolver(blendedImage(:, :, :, ch), blendedGradX, blendedGradY);
    end
end

function result = poissonSolver(initImage, gradX, gradY)
    % POISSONSOLVER Solves the Poisson equation to reconstruct an image from gradients.
    %
    % result = poissonSolver(initImage, gradX, gradY) reconstructs an image from
    % the input gradients using the Jacobi method.
    %
    % Input:
    %   initImage - The initial image guess.
    %   gradX     - The blended horizontal gradients.
    %   gradY     - The blended vertical gradients.
    %
    % Output:
    %   result - The reconstructed image.

    % Initialize the result with the initial image
    result = initImage;

    % Iterate to solve the Poisson equation
    for iter = 1:1000
        % Compute the divergence of the blended gradients for each slice
        div = zeros(size(result));
        for z = 1:size(result, 3)
            div(:, :, z) = computeDivergence(gradX(:, :, z), gradY(:, :, z));
        end

        % Update the result using the Jacobi method
        result(2:end-1, 2:end-1, :) = (result(1:end-2, 2:end-1, :) + result(3:end, 2:end-1, :) + ...
                                       result(2:end-1, 1:end-2, :) + result(2:end-1, 3:end, :) - div(2:end-1, 2:end-1, :)) / 4;
    end
end

function div = computeDivergence(gradX, gradY)
    % COMPUTEDIVERGENCE Computes the divergence of 2D gradients.
    %
    % div = computeDivergence(gradX, gradY) computes the divergence of the input
    % 2D gradients.
    %
    % Input:
    %   gradX - The horizontal gradients.
    %   gradY - The vertical gradients.
    %
    % Output:
    %   div - The divergence of the gradients.

    [rows, cols] = size(gradX);

    % Initialize the divergence
    div = zeros(rows, cols);

    % Compute divergence
    div(2:end-1, 2:end-1) = (gradX(3:end, 2:end-1) - gradX(2:end-1, 2:end-1)) + ...
                            (gradY(2:end-1, 3:end) - gradY(2:end-1, 2:end-1));
end
