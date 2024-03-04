function cnr = CalculateCNR(image, signalMask, noiseMask)
    % CalculateCNR Calculates the Contrast-to-Noise Ratio (CNR) between a signal and noise region in a grayscale image.
    %
    % This function computes the CNR between a signal region and a noise region in a grayscale image by
    % dividing the difference in mean intensity between the signal and noise regions by the average 
    % standard deviation of the intensities within those regions.
    %
    % Parameters:
    %   image - The input grayscale image.
    %   signalMask - A logical mask defining the signal region of interest.
    %   noiseMask - A logical mask defining the noise region of interest.
    %
    % Returns:
    %   cnr - The calculated Contrast-to-Noise Ratio.
    
    % Ensure the image is in double format for calculations
    image = double(image);
    
    % Calculate the mean intensity of the signal and noise regions
    meanSignal = mean(image(signalMask));
    meanNoise = mean(image(noiseMask));
    
    % Calculate the standard deviation of the intensities within the signal and noise regions
    % stdSignal = std(image(signalMask));
    stdNoise = max(eps, std(image(noiseMask)));
    
    % Calculate the contrast (difference in mean intensities between signal and noise)
    contrast = abs(meanSignal - meanNoise);
    
    % Calculate the average noise (average of the standard deviations of signal and noise regions)
    % noise = (stdSignal + stdNoise) / 2;
    
    % Calculate CNR
    cnr = contrast / stdNoise;
end
