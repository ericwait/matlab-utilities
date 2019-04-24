function colorIm = ColorImages(imIntensity,colors)
    if (ndims(imIntensity)>3)
        error('Wrong size image');% Make this a better message
    end
    
    numChans = size(colors,1);
    imColors = zeros(size(imIntensity,1),size(imIntensity,2),3,numChans,'single');
    imIntensity = double(imIntensity);
    
    colorMultiplier = zeros(1,1,3,length(numChans),'single');
    for c=1:numChans
        colorMultiplier(1,1,:,c) = colors(c,:);
    end
    
    for c=1:numChans
        im = imIntensity(:,:,c);
        im = mat2gray(im);
        im = ImUtils.BrightenImages(im,[],0.0005,20);
        im = ImUtils.BrightenImagesGamma(im,[],0.95,40);
        im = mat2gray(im);
        imIntensity(:,:,c) = im;
        color = repmat(colorMultiplier(1,1,:,c),size(im,1),size(im,2),1);
        imColors(:,:,:,c) = repmat(im,1,1,3).*color;
    end
            
    imMax = max(imIntensity,[],3);
    imIntSum = sum(imIntensity,3);
    imIntSum(imIntSum==0) = 1;
    imColrSum = sum(imColors,4);
    colorIm = imColrSum.*repmat(imMax./imIntSum,1,1,3);
    colorIm = im2uint8(colorIm);
end
