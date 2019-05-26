function [im,minVal,maxVal,clorMap] = ColorMapZeroCentered(imIn,negColors,posColors)
    minVal = min(imIn(:));
    maxVal = max(imIn(:));
    if (minVal>=0)
        clorMap = imresize(posColors,[256,3]);
    elseif (maxVal<=0)
        clorMap = imresize(negColors,[256,3]);
    else
        negDist = abs(minVal);
        posDist = maxVal;
        rng = negDist + posDist;
        negPrct = double(negDist)/double(rng);
        posPrct = double(posDist)/double(rng);
        bottomClor = imresize(negColors,[round(256*negPrct),3]);
        topClor = imresize(posColors,[round(256*posPrct),3]);
        clorMap = vertcat(bottomClor,topClor);
    end

    im = im2uint8(ind2rgb(round(mat2gray(imIn)*255),clorMap));
end
