function [ imageOut ] = imageConvertNorm( imageIn, imageData, typ, normalize)
%IMAGECONVERT converts image from current type into the specified type

if (~exist('normalize','var') || isempty(normalize))
    normalize = 0;
end

imageOut = zeros(size(imageIn),typ);

if (normalize)
    for t=1:imageData.NumberOfFrames
        for c=1:imageData.NumberOfChannels
            imTemp = double(imageIn(:,:,:,c,t));
            imTemp = imTemp-min(imTemp(:));
            imTemp = imTemp./max(imTemp(:));
            
            switch typ
                case 'uint8'
                    imageOut(:,:,:,c,t) = im2uint8(imTemp);
                case 'uint16'
                    imageOut(:,:,:,c,t) = im2uint16(imTemp);
                case 'int16'
                    imageOut(:,:,:,c,t) = im2int16(imTemp);
                case 'uint32'
                    imageOut(:,:,:,c,t) = im2uint32(imTemp);
                case 'int32'
                    imageOut(:,:,:,c,t) = im2int32(imTemp);
                case 'single'
                    imageOut(:,:,:,c,t) = im2single(imTemp);
                case 'double'
                    imageOut(:,:,:,c,t) = imTemp;
                case 'logical'
                    imageOut(:,:,:,c,t) = imTemp>min(imTemp(:));
                otherwise
                    error('Unkown type of image to convert to!');
            end
        end
    end
else
    w = whos('imageIn');
    if (strcmpi(w.class,typ))
        imageOut = imageIn;
    else
        switch typ
            case 'uint8'
                imageOut = im2uint8(imageIn);
            case 'uint16'
                imageOut = im2uint16(imageIn);
            case 'int16'
                imageOut = im2int16(imageIn);
            case 'uint32'
                imageOut = im2uint32(imageIn);
            case 'int32'
                imageOut = im2int32(imageIn);
            case 'single'
                imageOut = im2single(imageIn);
            case 'double'
                imageOut = im2double(imageIn);
            case 'logical'
                imageOut = imageIn>min(imageIn(:));
            otherwise
                error('Unkown type of image to convert to!');
        end
    end
end
end

