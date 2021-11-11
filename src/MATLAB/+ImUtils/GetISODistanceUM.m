function [im_dist_3d, im_dist_2d] = GetISODistanceUM(im_bw, meta)
    iso_voxel_size = min(meta.PixelPhysicalSize);
    new_size = size(im_bw,1:3) .* meta.PixelPhysicalSize ./ iso_voxel_size;

    im_frag_iso = imresize3(im_bw,new_size, 'method','nearest');
    
    im_dist_3d = bwdist(~im_frag_iso) .* iso_voxel_size;
    im_dist_2d = zeros(size(im_bw),'like',im_dist_3d);
    
    for z=1:size(im_dist_2d,3)
        im_dist_2d(:,:,z) = bwdist(~im_bw(:,:,z)) .* iso_voxel_size;
    end

    im_dist_3d = imresize3(im_dist_3d,size(im_bw),'Method','nearest');
    im_dist_2d = imresize3(im_dist_2d,size(im_bw),'Method','nearest');
end
