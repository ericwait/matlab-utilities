function tform = AffineRegister3D(fixedImg, movingImg)
    % AffineRegister3D - Perform a full affine registration between two 3D grayscale images.
    %
    % Syntax:
    %   tform = AffineRegister3D(fixedImg, movingImg)
    %
    % Inputs:
    %   fixedImg  - The reference 3D grayscale image to which the moving image will be aligned.
    %   movingImg - The 3D grayscale image that needs to be aligned to the fixed image.
    %
    % Output:
    %   tform     - The estimated affine transformation parameters for aligning movingImg to fixedImg.
    %
    % Example:
    %   tform = AffineRegister3D(fixedImg, movingImg);
    %
    % Note:
    %   The function will throw an error if either of the input images is not a 3D grayscale image.
    %   The function uses Mattes Mutual Information as the similarity metric and Regular Step Gradient Descent as the optimizer.
    %   The function also displays a pair of central slices from the fixed and registered moving images for visual inspection.

    % Check for 3D grayscale images
    if ndims(fixedImg) ~= 3 || ndims(movingImg) ~= 3
        error('Both images must be 3D grayscale images');
    end

    % Set the options for the registration
    optimizer = registration.optimizer.RegularStepGradientDescent();
    optimizer.MaximumIterations = 1e3;
    metric = registration.metric.MattesMutualInformation();
    
    % Estimate the affine transformation
    tform = imregtform(movingImg, fixedImg, 'affine', optimizer, metric, 'DisplayOptimization', false);

    % Display the optimizer's settings
    disp(optimizer);

    % Apply the transformation and visualize the result
    movingRegistered = imwarp(movingImg, tform, 'OutputView', imref3d(size(fixedImg)));
    
    % Display central slices from each volume for comparison
    central_slice = round(size(fixedImg, 3) / 2);
    figure('Name','Central Slices from Each Volume Before and After Registration');
    subplot(1, 3, 1)
    imshow(fixedImg(:,:,central_slice), []);
    title('Fixed Image Central Slice');
    
    subplot(1, 3, 2)
    imshow(movingImg(:,:,central_slice), []);
    title('Moving Image Central Slice');
    
    subplot(1, 3, 3)
    imshowpair(fixedImg(:,:,central_slice), movingRegistered(:,:,central_slice));
    title('Fixed and Registered Moving Images');
end
