function im = NormalizedClippedIntensities(im, minVal, maxVal)
    im = ImUtils.ClipIntensities(im, minVal, maxVal);
    im = im - minVal;
    im = single(im) / (maxVal - minVal);
end
