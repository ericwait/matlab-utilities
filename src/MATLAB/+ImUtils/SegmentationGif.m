function im_rgb = SegmentationGif(im, im_labels, file_path, file_name_wo_ext, gamma)
    if ~exist('gamma','var') || isempty(gamma)
        gamma = 0.6;
    end
    
    im_l_rgb = ImUtils.LabelToRGB(im_labels,[],true);
    im_rgb = zeros([size(im,1),size(im,2)*3,3,size(im,3:5)],'uint8');
        
    im_x_starts = [1, size(im,2), size(im,2)*2];
    im_x_ends = [1, 2, 3].* size(im,2);
        
    for z=1:size(im,3)
        cur_im = ImUtils.ConvertType(ImUtils.BrightenImagesGamma(im(:,:,z,:,:),'single',gamma),'single',true);
        cur_im = repmat(cur_im,[1,1,3,1,1]);
        
        im_rgb(:,im_x_starts(1):im_x_ends(1),:,z,:) = im2uint8(cur_im);
        im_rgb(:,im_x_starts(2):im_x_ends(2)-1,:,z,:) = im_l_rgb(:,:,:,z,:,:);
        im_rgb(:,im_x_starts(3):im_x_ends(3)-1,:,z,:) = im2uint8(im2single(im_l_rgb(:,:,:,z,:,:)) .* cur_im);
    end

    if exist('file_path', 'var') && ~isempty(file_path) && exist('file_name_wo_ext', 'var') && ~isempty(file_name_wo_ext)
        [imind,cm] = rgb2ind(im_rgb(:,:,:,1),256);
        imwrite(imind, cm, fullfile(file_path, [file_name_wo_ext, '.gif']), 'gif', 'loopcount', inf);
        for z = 2:size(im,3)
            [imind,cm] = rgb2ind(im_rgb(:,:,:,z),256);
            imwrite(imind, cm, fullfile(file_path, [file_name_wo_ext, '.gif']), 'gif', 'writemode', 'append');
        end
    end
end
