function ptsReplicate_xy = PixelReplicate(imSize_rc, indList, subsamplePrct)
    padding = max(9,max(imSize_rc.*0.05));
    [smallBw,startCoords_rcz] = ImUtils.ROI.MakeSubImBW(imSize_rc,indList,padding);
    startCoords_xy = Utils.SwapXY_RC(startCoords_rcz);

    bwd = bwdist(~smallBw);
    npts = sum(bwd(:));

    if (npts>1e6 || subsamplePrct<1.0)
        ptsReplicate_xy = RejectionSim(round(pct*npts), bwd);
    else
        indsReplicate = [];
        idx = find(bwd);
        % note - you could use a parfor here for speed with large components
        for i=1:length(idx)
            nrep = round(bwd(idx(i)));
            % speed up by using pre-allocated ptsReplicate
            indsReplicate = [indsReplicate;repmat(idx(i),nrep,1)];
        end
        ptsReplicate_xy = Utils.SwapXY_RC(Utils.IndToCoord(imSize_rc,indsReplicate));
    end
    
    ptsReplicate_xy = ptsReplicate_xy + startCoords_xy -1;
end

