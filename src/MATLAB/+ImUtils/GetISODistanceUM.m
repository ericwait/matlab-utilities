function im_dist_3d = GetISODistanceUM(im_bw, meta)
    [im_frag_iso, padded_im_size, iso_voxel_size] = ImUtils.CreateIsometricImage(im_bw, meta.PixelPhysicalSize);
    im_dist_3d = bwdist(~im_frag_iso) .* iso_voxel_size;

    im_dist_3d_padded = imresize3(im_dist_3d, padded_im_size, 'Method', 'nearest');

    im_dist_3d = ImUtils.UnpadImage(im_dist_3d_padded, size(im_bw));
end
