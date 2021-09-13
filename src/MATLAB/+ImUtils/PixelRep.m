function labels = PixelRep(voxel_list_xyz, expected_number_labels, voxel_anisotropy_xyz)

    if expected_number_labels==1
        labels = ones(size(voxel_list_xyz,1),1);
        return
    end

    im_roi = ImUtils.MakeBinaryROI(voxel_list_xyz);
    
    if exist('voxel_anisotropy_xyz','var') && ~isempty(voxel_anisotropy_xyz)
        iso_size = size(im_roi) .* (voxel_anisotropy_xyz./max(voxel_anisotropy_xyz));
        im_roi_iso = imresize3(im_roi,ceil(iso_size),'nearest');
    else
        im_roi_iso = im_roi;
    end

    ptsReplicated_xyz = ImUtils.PixelReplicate(im_roi_iso);
    
    % fit gmm to PR points
    % NOTE - more replicates is more accurate fit, but takes longer. you can
    % spmd this, or adjust as needed...
    warning('off','stats:gmdistribution:FailedToConvergeReps')
    warning('off','stats:gmdistribution:IllCondCov');
    objPR = fitgmdist(ptsReplicated_xyz, expected_number_labels, 'replicates',5);
    if ~objPR.Converged
%         fprintf(1,'PixelReplication -- GMM fit failed to converge. Retrying with more replicates and iterations\n');
        objPR = fitgmdist(ptsReplicated_xyz, expected_number_labels, 'replicates',50, 'Options',statset('Display','off','MaxIter',1500,'TolFun',1e-5));
        if ~objPR.Converged
            fprintf(1,'PixelReplication -- failed second attempt to fit GMM -- aborting\n');
            fprintf(1,' check that K value is appropriate, or increase number of replicates\n');
            labels = ones(size(voxel_list_xyz,1),1);
            return
        end
    end
    
    inds = find(im_roi_iso);
    coord_xyz = Utils.SwapXY_RC(Utils.IndToCoord(size(im_roi_iso), inds));
    labels = objPR.cluster(coord_xyz);
    
    im_label_iso = zeros(size(im_roi_iso));
    im_label_iso(inds) = labels;
    
    im_label = imresize3(im_label_iso, size(im_roi), 'nearest');
    labels = im_label(im_roi(:));
end
