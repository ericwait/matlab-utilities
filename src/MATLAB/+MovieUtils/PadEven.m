function imOut = PadEven(im)
    cPad = mod(size(im,2),2);
    rPad = mod(size(im,1),2);
    
    imOut = zeros(size(im,1)+rPad,size(im,2)+cPad,size(im,3),'like',im);
    imOut(1:size(im,1),1:size(im,2),:) = im;
end