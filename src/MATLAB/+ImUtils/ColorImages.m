function colorIm = ColorImages(imIntensity,colors)
    if (ndims(imIntensity)>3)
        error('Wrong size image');% Make this a better message
    end
    
    numChans = size(colors,1);
    imColors = zeros(size(imIntensity,1),size(imIntensity,2),3,numChans,'single');
    im = ImUtils.ConvertType(imIntensity, 'single', true);
    
    colorMultiplier = zeros(1,1,3,length(numChans),'single');
    for c=1:numChans
        colorMultiplier(1,1,:,c) = colors(c,:);
    end
    
    for c=1:numChans
        im_temp = im(:,:,c);
        color = repmat(colorMultiplier(1,1,:,c), size(im_temp));
        imColors(:,:,:,c) = repmat(im_temp,1,1,3) .* color;

        if islogical(imIntensity)
            continue
        end

        im_temp = ImUtils.BrightenImages(im_temp, [], 0.0005, 20);
        im_temp = ImUtils.BrightenImagesGamma(im_temp, [], 0.95, 0.04);
        im_temp = mat2gray(im_temp);
        im(:,:,c) = im_temp;
    end
            
    imMax = max(im,[],3);
    imIntSum = sum(im,3);
    imIntSum(imIntSum==0) = 1;
    imColrSum = sum(imColors,4);
    colorIm = imColrSum.*repmat(imMax./imIntSum,1,1,3);
    colorIm = im2uint8(colorIm);
end
