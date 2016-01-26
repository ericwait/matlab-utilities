% [ imageOut ] = ConvertType(IMAGEIN, OUTCLASS, NORMALIZE)
% ConvertType converts image from current type into the specified type
% OUTCLASS
% If normalize==true then each channel/frame will be set between [0,1] prior
% to conversion, meaning that normalization happens on a frame by frame as
% well as a channel by channel bases.
% Assumes a 5D image of (rows,col,z,channels,time). Non-existent dimensions
% should be singleton.

function [ imageOut ] = ConvertType(imageIn, typ, normalize)

if (~exist('normalize','var') || isempty(normalize))
    normalize = 0;
end

if (~strcmpi(typ,'logical'))
    imageOut = zeros(size(imageIn),typ);
else
    imageOut = false(size(imageIn));
end

if (normalize)
    for t=1:size(imageIn,5)
        for c=1:size(imageIn,4)
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
    switch w.class
        case 'single'
            imageIn = convertToMaxOfOne(imageIn,w.class);
        case 'double'
            imageIn = convertToMaxOfOne(imageIn,w.class);
    end
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

function im = convertToMaxOfOne(im,outTyp)
switch outTyp
    case 'uint8'
        im = im./2^8;
    case 'uint16'
        if (max(im(:))<2^12+1)
            im = im./2^12;
        else
            im = im./2^16;
        end
    case 'int16'
        im = im./2^15-1;
    case 'uint32'
        im = im./2^32;
    case 'int32'
        im = im./2^32-1;
    case 'single'
        im = im./max(im(:));
    case 'double'
        im = im./max(im(:));
    case 'logical'
        % im = im;
    otherwise
        error('Unkown type of image to convert to!');
end
end

