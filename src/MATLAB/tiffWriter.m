function tiffWriter(im,prefix,imageData)

if (exist('imageData','var') && ~isempty(imageData))
    idx = strfind(prefix,'\');
    if (isempty(idx))
        idx = length(prefix);
    end
    createMetadata(prefix(1:idx(end)),imageData);
end

sizes = size(im);
numDim = length(sizes);

if numDim<5
    frames= 1;
else
    frames = sizes(5);
end
if numDim<4
    channels = 1;
else
    channels = sizes(4);
end
if numDim<3
    stacks = 1;
else
    stacks = sizes(3);
end

imUint = im;

if (isa(im,'double') || isa(im,'single'))
    bits = [0 8 16 24 48];
    imTemp = [];
    
    mx = max(im(:));
    
    for i=1:length(bits)
        if (mx<2^(bits(i)))
            imTemp = im./(2^(bits(i))-1);
            break
        end
    end
    
    if (isempty(imTemp))
        imTemp = im./mx;
    end
    
    curNumBins = 2^bits(2)-1;

    imCur = round(imTemp*curNumBins)./curNumBins;
    normExpectedError = [sqrt(mean((imTemp(:)-imCur(:)).^2)) * 2^bits(2) 0];
    
    for i=3:length(bits)
        curNumBins = 2^bits(i)-1;
        
        imCur = round(imTemp*curNumBins)./curNumBins;
        normExpectedError(2) = sqrt(mean((imTemp(:)-imCur(:)).^2)) * 2^bits(i);
        
        if (abs(normExpectedError(1)-normExpectedError(2))<.001)
            break
        end
        
        normExpectedError(1) = normExpectedError(2);
    end
    
    curNumBins = 2^bits(i-1)-1;
    
    switch i
        case 3
            imUint = uint8(round(imTemp*curNumBins));
        case 4
            imUint = uint16(round(imTemp*curNumBins));
        otherwise
            disp('Bit depth too high');
            return
%         case 5
%             imUint = uint32(round(imTemp*curNumBins));
%         otherwise
%             imUint = uint64(round(imTemp*curNumBins));
    end
end

for t=1:frames
    for c=1:channels
        for z=1:stacks
            fileName = sprintf('%s_c%02d_t%04d_z%04d.tif',prefix,c,t,z);
            imwrite(imUint(:,:,z,c,t),fileName,'tif','Compression','lzw');
        end
    end
end

fprintf('Wrote %s_c%d_t%d_z%d.tif\n',prefix,channels,frames,stacks);

end

