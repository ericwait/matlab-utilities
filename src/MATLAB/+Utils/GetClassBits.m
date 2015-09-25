function [numBits, varargout] = GetClassBits( checkVar )
%CLASSBITS Summary of this function goes here
%   Detailed explanation goes here

switch class(checkVar)
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
    otherwise
        numBits = 0;
        minVal = 0;
        maxVal = 0;
end

nout = max(nargout,1) - 1;

if nout>1
    varargout{2} = maxVal;
end

if nout>0
    varargout{1} = minVal;
end

end

