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
