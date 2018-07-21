function imCorrected = CorrectFlatField(im,imFF,darkField)
    gain = imFF-darkField;
    gain = mean(gain(:))./gain;
    
    imCorrected = single(im) .* single(gain);
    imCorrected = ImUtils.ConvertType(imCorrected,class(im),true);
end