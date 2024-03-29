% [ imageOut ] = ConvertType(IMAGEIN, OUTCLASS, NORMALIZE, NORMBYFRAME, OPENINTERVAL)
% ConvertType converts image from current type into the specified type
% OUTCLASS
% If NORMALIZE is true, then each channel/frame will be set between [0,1] 
% prior to conversion. By default, normalization is global in time. Setting 
% NORMBYFRAME to true normalizes the image on a frame-by-frame as well as a
% channel-by-channel basis. OPENINTERVAL is a 2-element array specifying 
% the open interval used during normalization.
% Assumes a 5D image of (rows,col,z,channels,time). Non-existent dimensions
% should be singleton.

function [ imageOut ] = ConvertType(imageIn, typ, normalize, normByFrame, openInterval)

if (~exist('normalize','var') || isempty(normalize))
    normalize = 0;
end

if (~exist('normByFrame','var') || isempty(normByFrame))
    normByFrame = false;
end

if (~exist('openInterval','var') || isempty(openInterval))
    openInterval = [-Inf,Inf];
end

w = whos('imageIn');
if (strcmpi(w.class,typ) && ~normalize)
    imageOut = imageIn;
    return
end

if (strcmpi(w.class,'logical'))
    imageIn = single(imageIn);
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
        imageIn = single(imageIn)./single(maxTypes(4));
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
    inType = class(imageIn);
    
    mask = uint8(imageIn <= openInterval(1));
    mask = mask + uint8(imageIn >= openInterval(2));
    imTempNaNs = imageIn;
    imTempNaNs(mask(:) > 0) = NaN;
    
    if (normByFrame)
        minVals = min(imTempNaNs,[],[1,2,3],'omitnan');
        maxVals = max(imTempNaNs,[],[1,2,3],'omitnan');
    else
        minVals = min(imTempNaNs,[],[1,2,3,5],'omitnan');
        maxVals = max(imTempNaNs,[],[1,2,3,5],'omitnan');
    end

    clear imTempNaNs

    if (strcmpi(inType,'double') || strcmpi(inType,'uint64') || strcmpi(inType,'int64'))
        imTemp = double(imageIn);
        minVals = double(minVals);
        maxVals = double(maxVals);
    else
        imTemp = single(imageIn);
        minVals = single(minVals);
        maxVals = single(maxVals);
    end
    
    if (minVals ~= maxVals)
        imTemp = imTemp - minVals;
        imTemp = imTemp./(maxVals-minVals);
        imTemp(mask(:) == 1) = 0;
        imTemp(mask(:) == 2) = 1;
    end
          
    switch typ
        case 'uint8'
            imageOut = im2uint8(imTemp);
        case 'uint16'
            imageOut = im2uint16(imTemp);
        case 'int16'
            imageOut = im2int16(imTemp);
        case 'uint32'
            imageOut = uint32(imTemp*(2^32-1));
        case 'int32'
            imageOut = im2int32(imTemp);
        case 'single'
            imageOut = im2single(imTemp);
        case 'double'
            imageOut = im2double(imTemp);
        case 'logical'
            imageOut = imTemp>min(imTemp(:));
        otherwise
            error('Unkown type of image to convert to!');
    end

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
        im = im>min(im(:));
    otherwise
        error('Unkown type of image to convert to!');
end
end

