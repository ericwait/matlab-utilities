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

w = whos('imageIn');
if (strcmpi(w.class,typ) && ~normalize)
    imageOut = imageIn;
    return
end

if (~strcmpi(typ,'logical'))
    imageOut = zeros(size(imageIn),typ);
else
    imageOut = false(size(imageIn));
end

% deal with images that come in as 16 bit but are really a lesser bit depth
if (strcmpi(w.class,'uint16') && ~normalize)
    imMax = max(imageIn(:));
    maxTypes = [2^8-1,2^10-1,2^12-1,2^14-1];
    isBigger = maxTypes < double(imMax);
    if (isBigger(4))
        % truly a 16 bit image
        % do nothing
    elseif (isBigger(3))
        % is really a 14 bit image
        imageIn = single(imageIn)./single(maxTypes(3));
    elseif (isBigger(2))
        % is really a 12 bit image
        imageIn = single(imageIn)./single(maxTypes(3));
    elseif (isBigger(1))
        % is really a 10 bit image
        imageIn = single(imageIn)./single(maxTypes(2));
    else
        % is really a 8 bit image
        imageIn = single(imageIn)./single(maxTypes(1));
    end
end

if (normalize)
    %for t=1:size(imageIn,5)
    t=1:size(imageIn,5);
        for c=1:size(imageIn,4)
            inType = class(imageIn);
            if (strcmpi(inType,'double') || strcmpi(inType,'uint64') || strcmpi(inType,'int64'))
                imTemp = double(imageIn(:,:,:,c,t));
            else
                imTemp = single(imageIn(:,:,:,c,t));
            end
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
                    imageOut(:,:,:,c,t) = uint32(imTemp*(2^32-1));
                case 'int32'
                    imageOut(:,:,:,c,t) = im2int32(imTemp);
                case 'single'
                    imageOut(:,:,:,c,t) = im2single(imTemp);
                case 'double'
                    imageOut(:,:,:,c,t) = double(imTemp);
                case 'logical'
                    imageOut(:,:,:,c,t) = imTemp>min(imTemp(:));
                otherwise
                    error('Unkown type of image to convert to!');
            end
        end
    %end
else
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
        im = im./2^8-1;
    case 'uint16'
        if (max(im(:))<2^12)
            im = im./(2^12-1);
        elseif (max(im(:))<2^14)
            im = im./(2^14-1);
        else
            im = im./(2^16-1);
        end
    case 'int16'
        im = im./(2^16/2);
    case 'uint32'
        im = im./(2^32/2);
    case 'int32'
        im = im./(2^32/2);
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

