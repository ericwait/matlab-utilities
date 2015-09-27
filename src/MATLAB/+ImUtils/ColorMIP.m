function [imFinal] = ColorMIP(im,colors)
% COLORMIP takes a 4D images where the fourth dimension is the channel
% dimension and a list of RGB values were the row is the color to be
% applied to the channel with the same index.  Columns are RGB.
%
% The output is a uint8 colored image

numChannels = size(im,4);
numColors = size(colors,1);

if (numChannels ~= numColors)
    error('Wrong number of colors (%d) for %d channels!',numColors,numChannels);
end

colorMultiplier = zeros(1,1,3,length(numChannels));
for c=1:numChannels
    colorMultiplier(1,1,:,c) = colors(c,:);
end

%% make colored image
imColors = zeros(size(im,1),size(im,2),3,numChannels);
imIntensity = zeros(size(im,1),size(im,2),numChannels);
for c=1:numChannels
    imIntensity(:,:,c) = mat2gray(max(im(:,:,:,c),[],3));
    color = repmat(colorMultiplier(1,1,:,c),size(im,1),size(im,2),1);
    imColors(:,:,:,c) = repmat(imIntensity(:,:,c),1,1,3).*color;
end

imMax = max(imIntensity,[],3);
imIntSum = sum(imIntensity,3);
imIntSum(imIntSum==0) = 1;
imColrSum = sum(imColors,4);
imFinal = imColrSum.*repmat(imMax./imIntSum,1,1,3);
imFinal = im2uint8(imFinal);
end
