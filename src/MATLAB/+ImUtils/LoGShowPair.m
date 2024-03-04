function im = LoGShowPair(im,showResults)
    if (~exist('showResults','var') || isempty(showResults))
        showResults = true;
    end
    
    imMax = im;
    imMax(imMax<0) = 0;
    imMax = max(imMax,[],3);
    
    imMin = im;
    imMin(imMin>0) = 0;
    imMin = -imMin;
    imMin = max(imMin,[],3);
    
    if (showResults)
        imshowpair(imMax,imMin);
    end
    
    imMax2 = ImUtils.BrightenImagesGamma(imMax,'uint8', 1.0);
    imMin2 = ImUtils.BrightenImagesGamma(imMin,'uint8', 1.0);
    im = cat(3,imMin2,imMax2,imMin2);
end
