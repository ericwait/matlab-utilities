function PlaySegmentation(im, im_bw, gamma_factor)

    im_color = zeros([size(im_bw,[1,2]),3,size(im_bw,3)],'uint8');
    im_color(:,:,[1,3],:) = repmat(permute(im2uint8(im_bw),[1,2,4,3]),[1,1,2,1]);
    im_color(:,:,2,:) = ImUtils.BrightenImagesGamma(im,'uint8',gamma_factor);
    
    implay(im_color)
end
