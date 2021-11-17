function im_dist_3d = GetISODistanceUM(im_bw, meta)
    padding = 10;
    
    iso_voxel_size = min(meta.PixelPhysicalSize);
    new_size = round(size(im_bw,1:3) .* meta.PixelPhysicalSize ./ iso_voxel_size) + padding *2;

    im_bw_padded = ImUtils.PadImage(im_bw, [], padding);

    im_frag_iso = imresize3(im_bw_padded, new_size, 'method','nearest');
    im_dist_3d = bwdist(~im_frag_iso) .* iso_voxel_size;

    im_dist_3d_padded = imresize3(im_dist_3d,size(im_bw_padded),'Method','nearest');

    im_dist_3d = im_dist_3d_padded(padding:end-padding-1, padding:end-padding-1, padding:end-padding-1, :, :);
end
