function orthoSliceIm = MakeOrthoSliceProjections(im, colors, xyPhysicalSize, zPhysicalSize, scaleBar)
    zRatio = zPhysicalSize/xyPhysicalSize;
    
    imColor_xy = ImUtils.ColorImages(squeeze(max(im,[],3)),colors);

    im_xz = max(im,[],1);
    im_xz = permute(im_xz,[3,2,4,1]);
    imColor_xz = ImUtils.ColorImages(im_xz,colors);
    im_yz = max(im,[],2);
    im_yz = permute(im_yz,[1,3,4,2]);
    imColor_yz = ImUtils.ColorImages(im_yz,colors);

    imColor_xzR = imresize(imColor_xz,[round(size(imColor_xz,1)*zRatio),size(imColor_xz,2)]);
    imColor_yzR = imresize(imColor_yz,[size(imColor_yz,1),round(size(imColor_yz,2)*zRatio)]);

    orthoSliceIm = im2uint8(ones(size(imColor_xy,1)+size(imColor_xzR,1)+5,size(imColor_xy,2)+size(imColor_yzR,2)+5,3,'single')*0.35);
    orthoSliceIm(1:size(imColor_xy,1),1:size(imColor_xy,2),:) = imColor_xy;
    orthoSliceIm(size(imColor_xy,1)+6:size(imColor_xy,1)+5+size(imColor_xzR,1),1:size(imColor_xy,2),:) = imColor_xzR;
    orthoSliceIm(1:size(imColor_xy,1),size(imColor_xy,2)+6:size(imColor_xy,2)+5+size(imColor_yzR,2),:) = imColor_yzR;

    if exist("scaleBar", "var") && ~isempty(scaleBar)
        scaleBarLength = round(scaleBar / xyPhysicalSize);
        orthoSliceIm(end-40:end-20, end-20-scaleBarLength+1:end-20, :) = 255;
    end
end
