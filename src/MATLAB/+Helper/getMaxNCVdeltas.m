function [deltas,maxNCV] = getMaxNCVdeltas(im1,im2,minOverlapVolume)
%[deltas,maxNCV] = RegisterTwoImages(im1,im2,minOverlapVolume)
% DELTAS is the shift of the upper left coners ....

ncvMatrix = Helper.FFTNormalizedCovariance(im1,im2,minOverlapVolume);

[maxNCV,I] = max(ncvMatrix(:));

ncvCoords = calcImCoords(size(ncvMatrix),I);

deltas = ncvCoords - size(im2);
end