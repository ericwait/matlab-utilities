function labels = PixelRep(voxel_list_xyz, expected_number_labels, voxel_anisotropy_xyz)

    im_roi = ImUtils.MakeBinaryROI(voxel_list_xyz);
    
    if exist('voxel_anisotropy_xyz','var') && ~isempty(voxel_anisotropy_xyz)
        iso_size = size(im_roi) .* (voxel_anisotropy_xyz./max(voxel_anisotropy_xyz));
        im_roi_iso = imresize3(im_roi,ceil(iso_size),'nearest');
    else
        im_roi_iso = im_roi;
    end

    ptsReplicated_xyz = PixelReplicate(im_roi_iso);
    
    % fit gmm to PR points
    % NOTE - more replicates is more accurate fit, but takes longer. you can
    % spmd this, or adjust as needed...
    warning('off','stats:gmdistribution:FailedToConvergeReps')
    objPR = fitgmdist(ptsReplicated_xyz, expected_number_labels, 'replicates',5);
    if ~objPR.Converged
        fprintf(1,'PixelReplication -- GMM fit failed to converge. Retrying\n');
        objPR = fitgmdist(ptsReplicated_xyz, expected_number_labels, 'replicates',5);
        if ~objPR.Converged
            fprintf(1,'PixelReplication -- failed second attempt to fit GMM -- aborting\n');
            fprintf(1,' check that K value is appropriate, or increase number of replicates\n');
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
