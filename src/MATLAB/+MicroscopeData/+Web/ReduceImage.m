function [imOut] = ReduceImage(imIn,tileData,reductions,showProgress,useCUDAMex)
%REDUCEIMAGETEMP Summary of this function goes here
%   Detailed explanation goes here

if (~exist('showProgress','var') || isempty(showProgress))
    showProgress = false;
end

% if (showProgress)
%     PrintProgress(imDataIn.NumberOfFrames*imDataIn.NumberOfChannels,true,true);
%     i = 0;
% end
% make sure initialize with 'uint8', since zeros() default is double, which will cause a big problem when using imresize
% imOut = zeros(ceil(imDataIn.YDimension*scale),ceil(imDataIn.XDimension*scale),imDataIn.ZDimension,imDataIn.NumberOfChannels,imDataIn.NumberOfFrames,'uint8');
% imOut = zeros('uint8');

% cudaMex bug is still there

% useCUDAMex = 1;
% if(useCUDAMex)
% %     imOut = zeros(floor(imDataIn.YDimension*scale),floor(imDataIn.XDimension*scale),imDataIn.ZDimension,imDataIn.NumberOfChannels,imDataIn.NumberOfFrames,'uint8');
%     for t=1:imDataIn.NumberOfFrames
%         for c=1:imDataIn.NumberOfChannels
% %              imOut(:,:,:,c,t) = Cuda.Mex('ReduceImage',imIn(:,:,:,c,t),reductions,'median');
%              imOut(:,:,:,c,t) = Cuda.Mex('ReduceImage',imIn(:,:,:,c,t),reductions,'mean', 1);
% %             if (showProgress)
% %                 i = i + 1;
% % %                 PrintProgress(i);
% %             end
%         end
%     end
% else   
%     imOut = ReduceImageCPU(imIn, imDataIn, reductions);
% end

%% Downsample image 
imIn = imresize(imIn,[tileData.YDimension,tileData.XDimension]);    
imOut = uint8(imIn);

% if (showProgress)
% %     PrintProgress(0,false);
% end
 end

