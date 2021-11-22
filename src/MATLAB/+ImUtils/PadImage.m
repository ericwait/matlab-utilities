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
    if (any(padding<0))
        error('New image needs to be bigger than the input');
    end
    starts = padding +1;
    ends = starts+size(imIn)-1;
    if ndims(starts)<3
        starts(3) = 1;
    end
    if ndims(ends)<3
        ends(3) = 1;
    end
    
    if (islogical(imIn))
        imPadded = false(newSize);
    else
        imPadded = zeros(newSize,'like',imIn);
    end
    
    imPadded(starts(1):ends(1),starts(2):ends(2),starts(3):ends(3),:,:) = imIn;
end
