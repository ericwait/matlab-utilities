%labeledPixels = Segmentation.GapPixelRep(imSize_rc, indList, K_MAX, showplots, turnOffGMMwarn)
function labeledPixels = GapPixelRep(imSize_rc, indList, K_MAX, showplots, turnOffGMMwarn)
    if (~exist('showplots','var') || isempty(showplots))
        showplots = false;
    end
    
    if (K_MAX<=1)
        labeledPixels = ones(length(indList),1);
        return
    end
    
    if (~exist('turnOffGMMwarn','var') || isempty(turnOffGMMwarn))
        turnOffGMMwarn = false;
    end
    
    if (turnOffGMMwarn)
        warning('off','stats:gmdistribution:FailedToConvergeReps');
        warning('off','MATLAB:singularMatrix');
        warning('off','MATLAB:illConditionedMatrix');
        warning off backtrace
        warning off verbose
    end
    
    pixelsOrg_rc = Utils.IndToCoord(imSize_rc,indList);
    B = 50;
    
    [~,~,V] = svd(pixelsOrg_rc,0);
    
    princeipleComp = pixelsOrg_rc * V;
    
    maxExtents = max(princeipleComp);
    minExtents = min(princeipleComp);
    
    pixelsRep_rc = Utils.SwapXY_RC(Segmentation.PixelReplicate(imSize_rc,indList));
    
    k_b = pixelsRep_rc;
       
    for i=1:B
        k_b = cat(3,k_b,MakeData(V,size(pixelsRep_rc,1),maxExtents,minExtents));
    end
    
    curAx = [];
    if(showplots)
        fH = figure;
        curAx = axes('parent',fH,'color',[1,1,1]);
        h = subplot(2,5,[1,2]);
        plot(h,k_b(:,2,2),k_b(:,1,2),'.b');
        hold(h,'on');
        plot(h,k_b(:,2,1),k_b(:,1,1),'.r');
        axis(h,'image');
        axis(h,'ij');

        h = subplot(2,5,[6,7]);
        smallBw = ImUtils.ROI.MakeSubImBW(imSize_rc,indList,ceil(max(imSize_rc)*0.01));
        ImUtils.ThreeD.ShowMaxImage(smallBw,false,3,h);
    end
    
    k = Segmentation.GapGetBestK(K_MAX,k_b,fH);
    
    if (k<=1)
        labeledPixels = ones(size(pixelsOrg_rc,1),1);
    else
        try
            gmModel = fitgmdist(pixelsOrg_rc,k,'Replicates',5,'Options',statset('Display','off','MaxIter',200,'TolFun',1e-6));
            labeledPixels = cluster(gmModel,pixelsOrg_rc);
        catch err
            warning(err.message);
            labeledPixels = ones(size(pixelsOrg_rc,1),1);
        end
    end
    
    if (turnOffGMMwarn)
        warning('on','stats:gmdistribution:FailedToConvergeReps');
        warning('on','MATLAB:singularMatrix');
        warning('on','MATLAB:illConditionedMatrix');
        warning on backtrace
        warning on verbose
    end
end

