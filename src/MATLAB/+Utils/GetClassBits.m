function [numBits, minVal, maxVal, clss] = GetClassBits( checkVar, isNormalized )
%[numBits, minVal, maxVal, clss] = GetClassBits( checkVar, isNormalized )
%   Detailed explanation goes here

if (~exist('isNormalized','var') || isempty(isNormalized))
    isNormalized = false;
end

clss = class(checkVar);
switch clss
    case 'uint8'
        numBits = 8;
        minVal = 0;
        maxVal = 255;
    case 'uint16'
        numBits = 16;
        minVal = 0;
        maxVal = 2^16 -1;
    case 'uint32'
        numBits = 32;
        minVal = 0;
        maxVal = 2^32 -1;
    case 'int32'
        numBits = 32;
        minVal = 2^32 /2;
        maxVal = 2^32 /2 -1;
    case 'single'
        numBits = 32;
        if (isNormalized)
            minVal = 0;
            maxVal = 1;
        else
            minVal = realmin('single');
            maxVal = realmax('single');
        end
    case 'double'
        numBits  = 64;
        if (isNormalized)
            minVal = 0;
            maxVal = 1;
        else
            minVal = realmin('double');
            maxVal = realmax('double');
        end
    case 'logical'
        numBits = 1;
        minVal = false;
        maxVal = true;
    otherwise
        error('Unkown class!');
end
end

