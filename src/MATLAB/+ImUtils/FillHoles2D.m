function im_bw = FillHoles2D(im_bw)
    for t = 1:size(im_bw, 5)
        for c = 1:size(im_bw, 4)
            cur_vol = im_bw(:,:,:,c,t);
            parfor z=1:size(cur_vol, 3)
                cur_vol(:,:,z) = imfill(cur_vol(:,:,z), 'holes');
            end
            im_bw(:,:,:,c,t) = cur_vol;
        end
    end
end
