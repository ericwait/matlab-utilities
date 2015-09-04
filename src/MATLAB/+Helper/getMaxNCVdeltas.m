function [deltas,maxNCV] = getMaxNCVdeltas(im1,im2,minOverlapVolume,maxSearchSize,orginCoords)
%[deltas,maxNCV] = RegisterTwoImages(im1,im2,minOverlapVolume)
% DELTAS is the shift of the upper left coners ....

if (~exist('orginCoords','var') || isempty(orginCoords))
    orginCoords = zeros(ndims(im2));
end

ncvMatrix = Helper.FFTNormalizedCovariance(im1,im2,minOverlapVolume);

%% cut out the region of interest
dims = ndims( ncvMatrix );
subsCell2 = cell(1, dims );

cntrPt = size(im2) - orginCoords;
searchBounds =  [max(cntrPt - maxSearchSize, ones(1,ndims(im2)));...
                  min(cntrPt + maxSearchSize, size(ncvMatrix))];
              
fullOrgin = cntrPt - searchBounds(1,:) +1;
             
%actualSearch = min(size(im2),maxSearchSize*ones(1,ndims(im2)));

for d = 1:dims
    subsCell2{d} = searchBounds(1,d):searchBounds(2,d);
end

refStruct = struct('type','()','subs',{subsCell2});
ncvMatrixROI = subsref( ncvMatrix, refStruct);

%% get the best ncv
[maxNCV,I] = max(ncvMatrixROI(:));
ncvCoords = calcImCoords(size(ncvMatrixROI),I);

%% return the best coordinate
deltas = ncvCoords - fullOrgin;

% if (dims==3)
%      [X,Y] = meshgrid(1:size(ncvMatrix,2),1:size(ncvMatrix,1));
%     X = X - (size(im2,2) + orginCoords(1));
%     Y = Y - (size(im2,1) + orginCoords(2));
%     figure
%     
%     subplot(1,2,1);
%     if (dims<3)
%         surf(X,Y,ncvMatrix,'LineStyle','none');
%     else
%         surf(X,Y,ncvMatrix(:,:,ncvCoords(3)+1),'LineStyle','none');
%     end
%     
%     subplot(1,2,2);
%     [X,Y] = meshgrid(1:size(ncvMatrixROI,2),1:size(ncvMatrixROI,1));
%     X = X - fullOrgin(2);
%     Y = Y - fullOrgin(1);
%     if (dims<3)
%         surf(X,Y,ncvMatrixROI,'LineStyle','none');
%     else
%         surf(X,Y,ncvMatrixROI(:,:,ncvCoords(3)+1),'LineStyle','none');
%     end
% end
end