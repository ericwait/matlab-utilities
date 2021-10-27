function PlayPair(im1,im2)
    im1 = ImUtils.ConvertType(im1,'single',true);
    im2 = ImUtils.ConvertType(im2,'single',true);
    im = cat(2,im1,im2);
    
    if size(im,3)==3 || size(im,3)==1
        implay(im);
    else
        implay(permute(im,[1,2,4,3]));
    end
end