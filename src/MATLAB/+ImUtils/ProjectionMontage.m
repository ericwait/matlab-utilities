function im_ortho = ProjectionMontage(im, pixelPhysicalSize, colors, scale_bar_size)
    if nargin<4
        scale_bar_size = 100;
    end

    projection_types = {'min', 'max', 'mean', 'median', 'mode', 'std'};
    im_ortho = [];
    
    for pt = 1:length(projection_types)
        im_ortho_strip = ImUtils.MakeOrthoSliceProjections(im(:,:,:,:,1), colors, pixelPhysicalSize, scale_bar_size, projection_types{pt});
        horz_space = ones(10, size(im_ortho_strip, 2), 3, 'like', im_ortho_strip) .* 255;
    
        for t=2:size(im,5)
            im_ortho_temp = ImUtils.MakeOrthoSliceProjections(im(:,:,:,:,t), colors, pixelPhysicalSize, scale_bar_size, projection_types{pt});
            im_ortho_strip = cat(1, im_ortho_strip, horz_space, im_ortho_temp);
        end        

        vert_space = ones(size(im_ortho_strip, 1), 10, 3, 'like', im_ortho_strip) .* 255;
    
        im_ortho = cat(2, im_ortho, vert_space, im_ortho_strip);
    end
end
