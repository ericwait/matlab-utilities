function [imOut] = ReduceImage(imIn,tileData,reductions,showProgress)
%REDUCEIMAGETEMP Summary of this function goes here
%   Detailed explanation goes here

if (~exist('showProgress','var') || isempty(showProgress))
    showProgress = false;
end

OutDims = [tileData.Dimensions(2),tileData.Dimensions(1),tileData.Dimensions(3)];
%% Downsample image 

if reductions(3) ~= 1
    sampleZ = round(linspace(1,size(imIn,3),tileData.Dimensions(3)));
    imIn = imIn(:,:,sampleZ);
end
imOut = imresize(imIn,[tileData.Dimensions(2),tileData.Dimensions(1)],'method','bilinear');



% if all(size(imIn) == OutDims)
% imOut= imIn; return;
% end 
% imOut = ImProc.Resize(imIn,[],OutDims,'mean');


% imOut = im2uint8(imIn);
%Utils.PrintTime(toc)
% if (showProgress)
% %     PrintProgress(0,false);
% end
 end

