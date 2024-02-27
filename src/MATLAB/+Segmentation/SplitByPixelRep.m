%function [ labelIm ] = Segmentation.SplitByPixelRep( imSize_rc, indList, K, subsamplePrct)
%   Inputs:
%       imSize_rc - This is the image dimensions that indList was derived. Use
%           the results from size(im);
%       indList - This is the indices of the pixels/voxels of the object that
%           should be replicated.
%       K - This is the number of components to split the object into.
%       subsamplePrct - (optional) This is the percentage of the points that will be used
%           from the original set to replicate. This is done for all lists that
%           have more than 1e6 points in it.
%   Outputs:
%       labels - This is a list of labels the same length as indList and is
%           the label corresponding to each index.
%       labelIm - This is an image with the same dimensions as imSize_rc
%           where each position in the indList is set to the object label.

function [idx, labelIm] = SplitByPixelRep( imSize_rc, indList, K, subsamplePrct)
    if (~exist('subsamplePrct','var'))
        subsamplePrct = [];
    end
    ptsReplicated = Segmentation.PixelReplicate(imSize_rc, indList, subsamplePrct);


    warning('off', 'all')
    try
        objPR = fitgmdist(ptsReplicated, K, 'replicates',5);
    catch err
        [idx, labelIm] = Default(imSize_rc, indList);
        return
    end
    warning('on', 'all')

    coord_xy = Utils.SwapXY_RC(Utils.IndToCoord(imSize_rc,indList));
    try
    idx = objPR.cluster(coord_xy);
    catch err
        [idx, labelIm] = Default(imSize_rc, indList);
        return
    end

    if (nargout>1)
        labelIm = zeros(imSize_rc);
        for i=1:K
            curInds = indList(idx==i);
            labelIm(curInds) = i;
        end
    end
end

function [idx, labelIm] = Default(imSize_rc, indList)
    idx = ones(size(indList));
    labelIm = zeros(imSize_rc, 'uint16');
    labelIm(indList) = 1;
end