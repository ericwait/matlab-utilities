function imCropped = UnpadImage(imPadded, originalSize)
    if isempty(originalSize)
        error('Original image size must be specified');
    end
    
    paddedSize = size(imPadded);
    padding = round((paddedSize - originalSize) / 2);
    
    if any(padding < 0)
        error('Padded image needs to be bigger than the original image for unpadding');
    end
    
    starts = padding + 1;
    ends = starts + originalSize - 1;
    
    if length(starts) < 3
        starts(3) = 1;
    end
    
    if length(ends) < 3
        ends(3) = 1;
    end
    
    imCropped = imPadded(starts(1):ends(1), starts(2):ends(2), starts(3):ends(3), :, :);
end
