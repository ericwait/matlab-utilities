function labels = Watershed(voxel_list_xyz, min_dist, voxel_anisotropy_xyz)
    im_roi = ImUtils.MakeBinaryROI(voxel_list_xyz);
    
    if exist('voxel_anisotropy_xyz','var') && ~isempty(voxel_anisotropy_xyz)
        iso_size = size(im_roi) .* (voxel_anisotropy_xyz./min(voxel_anisotropy_xyz));
        im_roi_iso = imresize3(im_roi,ceil(iso_size),'linear');
    else
        im_roi_iso = im_roi;
    end

    D = bwdist(~im_roi_iso);    
    D2 = -D;
    D2(~im_roi_iso) = inf;
    if exist('min_dist','var') && ~isempty(min_dist)
        D3 = imhmin(D2,min_dist);
    else
        D3 = D2;
    end
    im_l = watershed(D3,26);
    im_l(~im_roi_iso) = 0;
    
    im_l = imresize3(im_l,size(im_roi),'nearest');
    
    labels = im_l(im_roi(:));
end