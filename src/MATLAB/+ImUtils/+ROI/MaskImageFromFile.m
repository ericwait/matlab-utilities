function [imOut] = MaskImageFromFile( im, fileName )
%MASKIMAGEFROMFILE Summary of this function goes here
%   Detailed explanation goes here

if (~exist('fileName','var') || isempty(fileName))
    [fName,dName,~] = uigetfile('*.tif');
    if (any(fName==0))
        imOut = im;
        return
    end
    fileName = fullfile(dName,fName);
end

bw = imread(fileName);

if (any(size(bw) ~= [size(im,1),size(im,2)]))
    error('Mask image does not have the same X,Y size as the passed in image');
end

sz = size(im);
repmatSz = [1,1,sz];

bw = repmat(bw,repmatSz);

imOut = zeros(size(im),'like',im);

imOut(bw) = im(bw);

end

