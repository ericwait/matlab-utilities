function im_dist_3d = GetISODistanceUM(im_bw, meta)
    [im_frag_iso, padded_im_size] = ImUtils.CreateIsometricImage(im_bw, meta.PixelPhysicalSize, 10);
    im_dist_3d = bwdist(~im_frag_iso) .* iso_voxel_size;

    im_dist_3d_padded = imresize3(im_dist_3d, padded_im_size, 'Method', 'nearest');

    im_dist_3d = im_dist_3d_padded(padding:end-padding-1, padding:end-padding-1, padding:end-padding-1, :, :);
end
