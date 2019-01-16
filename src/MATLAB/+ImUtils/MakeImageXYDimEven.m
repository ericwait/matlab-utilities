function im = MakeImageXYDimEven(im)
    sizeEven = size(im)/2;
    sizeEven = sizeEven([1,2]);
    sizeEven = sizeEven~=round(sizeEven);
    if (any(sizeEven))
        im(end:end+sizeEven(1),end:end+sizeEven(2),:) = 0;
    end
end
