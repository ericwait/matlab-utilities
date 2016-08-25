%function ptsReplicate_xy = Segmentation.PixelReplicate(imSize_rc, indList, subsamplePrct)
%   Inputs:
%       imSize_rc - This is the image dimensions that indList was derived. Use
%           the results from size(im);
%       indList - This is the indices of the pixels/voxels of the object that
%           should be replicated.
%       subsamplePrct - (optional) This is the percentage of the points that will be used
%           from the original set to replicate. This is done for all lists that
%           have more than 1e6 points in it.
%   Outputs:
%       ptsReplicate_xy - This is a multiset of the orignal points. This list
%           will have the dimensions n x d, where n is the number of points
%           after replication and d is the dimension of imSize_rc.

function ptsReplicate_xy = PixelReplicate(imSize_rc, indList, subsamplePrct)
    if (~exist('subsamplePrct','var') || isempty(subsamplePrct))
        subsamplePrct = 1.0;
    end
    
    padding = max(9,max(imSize_rc.*0.05));
    [smallBw,startCoords_rcz] = ImUtils.ROI.MakeSubImBW(imSize_rc,indList,padding);
    idx = find(smallBw(:));
    startCoords_xy = Utils.SwapXY_RC(startCoords_rcz);

    bwd = bwdist(~smallBw);
    npts = sum(bwd(:));

    if (npts>1e6 || subsamplePrct<1.0)
        if (subsamplePrct == 1.0)
            getNumPts = round(npts * 0.3);
        else
            getNumPts = round(npts * subsamplePrct);
        end
        ptsReplicate_xy = Segmentation.RejectionSim(getNumPts, bwd);
    else
        indsReplicate = [];
        for i=1:length(idx)
            nrep = round(bwd(idx(i)));
            indsReplicate = [indsReplicate;repmat(idx(i),nrep,1)];
        end
        ptsReplicate_xy = Utils.SwapXY_RC(Utils.IndToCoord(imSize_rc,indsReplicate));
    end
    
    ptsReplicate_xy = ptsReplicate_xy + repmat(startCoords_xy,size(ptsReplicate_xy,1),1) -1;
end
