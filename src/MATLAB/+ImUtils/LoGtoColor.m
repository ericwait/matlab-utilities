function [ imC ] = LoGtoColor( imLoG )
%LOGTOCOLOR Summary of this function goes here
%   Detailed explanation goes here

lclEps = 1e-4;

maskNeg = imLoG<-lclEps;
maskZero = -lclEps<imLoG & imLoG<lclEps;
maskPos = imLoG>lclEps;

imNeg = imLoG;
imNeg(~maskNeg) = 0;
imNeg = abs(imNeg);
imNeg = ImUtils.ConvertType(imNeg,'uint8',true);

imZero = imLoG;
imZero(~maskZero) = 0;
imZero = abs(imZero);
imZero = ImUtils.ConvertType(imZero,'uint8',true);

imPos = imLoG;
imPos(~maskPos) = 0;
imPos = abs(imPos);
imPos = ImUtils.ConvertType(imPos,'uint8',true);

colDim = ndims(imLoG) +1;

imC = cat(colDim,imNeg,imZero,imPos);
end
