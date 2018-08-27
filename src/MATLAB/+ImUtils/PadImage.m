function imPadded = PadImage(imIn,newSize,padding)
    if (~exist('padding','var'))
        if (isempty(newSize))
            error('Either a new image size or padding must be specified');
        end
    end
    
    if (isempty(newSize))
        newSize = size(imIn)+2*padding;
    end
    
    padding = round((newSize - size(imIn))/2);
    starts = padding +1;
    ends = newSize-padding;
    
    if (islogical(imIn))
        imPadded = false(newSize);
    else
        imPadded = zeros(newSize,'like',imIn);
    end
    
    imPadded(starts(1):ends(1),starts(2):ends(2),starts(3):ends(3),:,:) = imIn;
end
