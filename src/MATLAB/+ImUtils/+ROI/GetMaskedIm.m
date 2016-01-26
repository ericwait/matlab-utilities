function im = GetMaskedIm(im,bw,boundInd)
    grayIm = rgb2gray(im);
    grayIm = repmat(grayIm,1,1,3);
    bwMask = repmat(bw,1,1,3);
    
    im(~bwMask) = grayIm(~bwMask);
    im(boundInd) = 255;
    im(boundInd+numel(bw)) = 255;
    im(boundInd+numel(bw)*2) = 0;
end

