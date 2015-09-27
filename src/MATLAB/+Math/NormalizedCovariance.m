function [ ncv ] = NormalizedCovariance(signal1, signal2)
%NORMALIZEDCOVARIANCE takes two signals and gives the normalized covariance
%between them.

signal1 = double(signal1);
signal2 = double(signal2);
sig1 = sqrt(var(signal1(:)));
sig2 = sqrt(var(signal2(:)));

mean1 = mean(signal1(:));
mean2 = mean(signal2(:));

imSub1 = signal1 - mean1;
imSub2 = signal2 - mean2;

imMul = imSub1.*imSub2;

numerator = sum(imMul(:));

ncv = numerator / (numel(signal1)*sig1*sig2);
end

