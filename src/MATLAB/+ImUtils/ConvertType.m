function [imageOut] = ConvertType(imageIn, outClass, normalize, normByFrame, openInterval)
    % ConvertType converts an image from its current type into the specified type.
    %
    % Syntax:
    % [imageOut] = ConvertType(imageIn, outClass, normalize, normByFrame, openInterval)
    %
    % Description:
    % This function converts the input image (imageIn) to a specified output class (outClass).
    % Optionally, it can normalize the image data before conversion.
    % The function assumes the input image is a 5D image of dimensions (rows, cols, z, channels, time).
    % Non-existent dimensions should be singleton.
    %
    % Input Arguments:
    % - imageIn: The input image to be converted. It can be of any numeric or logical class.
    % - outClass: The desired output class. Supported classes include 'uint8', 'uint16', 'int16', 'uint32', 'int32', 'single', 'double', and 'logical'.
    % - normalize: (Optional) Boolean flag indicating whether to normalize the image data. Default is false.
    %   * If true, each channel/frame will be normalized to the range [0,1] before conversion.
    %   * If false, normalization is not applied.
    % - normByFrame: (Optional) Boolean flag indicating whether to normalize the image on a frame-by-frame basis. Default is false.
    %   * If true, normalization is applied individually to each frame and channel.
    %   * If false, normalization is applied globally across the entire image.
    % - openInterval: (Optional) 2-element array specifying the open interval used during normalization. Default is [-Inf, Inf].
    %
    % Output Arguments:
    % - imageOut: The converted image in the specified output class.
    %
    % Detailed Behavior:
    % - If normalization is not requested and the input image is already of the desired type, the input image is returned as-is.
    % - Logical images are first converted to 'single' for further processing.
    % - The function handles images that come in as 16-bit but are really of a lesser bit depth.
    % - If normalization is requested:
    %   * Values outside the specified open interval are set to NaN and omitted during normalization.
    %   * If normByFrame is true, normalization is applied to each frame and channel individually.
    %   * Otherwise, normalization is applied globally.
    % - If normalization is not requested and the input is floating-point while the output is integer:
    %   * An input value of 1 will be mapped to the maximum value of the output type.
    %   * All other values will be clipped to the range [0, 1].
    % - If normalization is not requested and the input is integer while the output is floating-point:
    %   * The maximum value of the input type will be mapped to 1 in the output type.
    %
    % Example Usage:
    % imageOut = ConvertType(imageIn, 'uint8', true, false, [0, 255]);
    % imageOut = ConvertType(imageIn, 'double');
    %
    % See also: im2uint8, im2uint16, im2int16, im2uint32, im2int32, im2single, im2double

    % Set default values for optional parameters
    if (~exist('normalize', 'var') || isempty(normalize))
        normalize = false;
    end

    if (~exist('normByFrame', 'var') || isempty(normByFrame))
        normByFrame = false;
    end

    if (~exist('openInterval', 'var') || isempty(openInterval))
        openInterval = [-Inf, Inf];
    end

    % If the image is already of the desired type and normalization is not needed, return the input
    w = whos('imageIn');
    if strcmpi(w.class, outClass) && ~normalize
        imageOut = imageIn;
        return;
    end

    % Convert logical images to single for further processing
    if strcmpi(w.class, 'logical')
        imageIn = single(imageIn);
    end

    % Handle 16-bit images that are actually of a lesser bit depth
    imageIn = handleLesserBitDepth(imageIn, w.class, normalize);

    % Normalize the image if required
    if normalize
        imageIn = normalizeImage(imageIn, normByFrame, openInterval);
    end

    % Convert the image to the desired output class
    imageOut = convertToClass(imageIn, outClass, normalize);
end

function imageIn = handleLesserBitDepth(imageIn, classType, normalize)
    % Handle images that come in as 16 bit but are really a lesser bit depth
    if strcmpi(classType, 'uint16') && ~normalize
        imMax = max(imageIn(:));
        maxTypes = [2^8-1, 2^10-1, 2^12-1, 2^14-1];
        isBigger = maxTypes < double(imMax);
        if isBigger(4)
            % Truly a 16-bit image, do nothing
        elseif isBigger(3)
            % Is really a 14-bit image
            imageIn = single(imageIn) ./ single(maxTypes(4));
        elseif isBigger(2)
            % Is really a 12-bit image
            imageIn = single(imageIn) ./ single(maxTypes(3));
        elseif isBigger(1)
            % Is really a 10-bit image
            imageIn = single(imageIn) ./ single(maxTypes(2));
        else
            % Is really an 8-bit image
            imageIn = single(imageIn) ./ single(maxTypes(1));
        end
    end
end

function imageIn = normalizeImage(imageIn, normByFrame, openInterval)
    % Normalize the image
    mask = uint8(imageIn <= openInterval(1)) + uint8(imageIn >= openInterval(2));
    imTempNaNs = imageIn;
    imTempNaNs(mask(:) > 0) = NaN;

    if normByFrame
        minVals = min(imTempNaNs, [], [1, 2, 3], 'omitnan');
        maxVals = max(imTempNaNs, [], [1, 2, 3], 'omitnan');
    else
        minVals = min(imTempNaNs, [], [1, 2, 3, 5], 'omitnan');
        maxVals = max(imTempNaNs, [], [1, 2, 3, 5], 'omitnan');
    end

    if minVals ~= maxVals
        imTemp = single(imageIn);
        minVals = single(minVals);
        maxVals = single(maxVals);
        imTemp = (imTemp - minVals) ./ (maxVals - minVals);
        imTemp(mask(:) == 1) = 0;
        imTemp(mask(:) == 2) = 1;
    else
        imTemp = imageIn;
    end

    imageIn = imTemp;
end

function imageOut = convertToClass(imageIn, outClass, normalize)
    % Convert the image to the desired output class
    switch outClass
        case 'uint8'
            if ~normalize && isfloat(imageIn)
                imageIn = min(max(imageIn, 0), 1); % Clip to [0, 1]
                imageOut = uint8(imageIn * (2^8-1));
            else
                imageOut = im2uint8(imageIn);
            end
        case 'uint16'
            if ~normalize && isfloat(imageIn)
                imageIn = min(max(imageIn, 0), 1); % Clip to [0, 1]
                imageOut = uint16(imageIn * (2^16-1));
            else
                imageOut = im2uint16(imageIn);
            end
        case 'int16'
            if ~normalize && isfloat(imageIn)
                imageIn = min(max(imageIn, -1), 1); % Clip to [-1, 1]
                imageOut = int16(imageIn * (2^15-1));
            else
                imageOut = im2int16(imageIn);
            end
        case 'uint32'
            if ~normalize && isfloat(imageIn)
                imageIn = min(max(imageIn, 0), 1); % Clip to [0, 1]
                imageOut = uint32(imageIn * (2^32-1));
            else
                imageOut = im2uint32(imageIn);
            end
        case 'int32'
            if ~normalize && isfloat(imageIn)
                imageIn = min(max(imageIn, -1), 1); % Clip to [-1, 1]
                imageOut = int32(imageIn * (2^31-1));
            else
                imageOut = im2int32(imageIn);
            end
        case 'single'
            if ~normalize && ~isfloat(imageIn)
                imageOut = single(imageIn) / double(intmax(class(imageIn)));
            else
                imageOut = im2single(imageIn);
            end
        case 'double'
            if ~normalize && ~isfloat(imageIn)
                imageOut = double(imageIn) / double(intmax(class(imageIn)));
            else
                imageOut = im2double(imageIn);
            end
        case 'logical'
            imageOut = imageIn > min(imageIn(:));
        otherwise
            error('Unknown type of image to convert to!');
    end
end
