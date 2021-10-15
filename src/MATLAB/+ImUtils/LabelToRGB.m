function im_rgb = LabelToRGB(label_im, color_map, verbose)
    if ~exist('verbose','var') || isempty(verbose)
        verbose = false;
    end

    num_labels = max(label_im(:));
    
    if ~exist('color_map','var') || isempty(color_map)
        color_map = lines(num_labels);
    end
    
    unique_labels = unique(label_im(:));
    unique_labels = unique_labels(unique_labels>0);
    if length(unique_labels)>size(color_map,1)
        error('There are not enough colors in the color map for %d labels',length(unique_labels));
    end

    im_rgb = zeros([size(label_im,1:2),3,size(label_im,3:5)]);
    colors = lines(num_labels);
    
    if verbose
        prgs = Utils.CmdlnProgress(length(unique_labels),true,'Coloring labels');
    end
    
    for l = 1:length(unique_labels)
        label_mask = label_im == unique_labels(l);
        
        im_r = im_rgb(:,:,1,:,:);
        im_g = im_rgb(:,:,2,:,:);
        im_b = im_rgb(:,:,3,:,:);
        
        im_r(label_mask) = colors(l,1);
        im_g(label_mask) = colors(l,2);
        im_b(label_mask) = colors(l,3);
        
        im_rgb = cat(3,im_r,im_g,im_b);
        
        if verbose
            prgs.PrintProgress(l);
        end
    end
    if verbose
        prgs.ClearProgress(true);
    end
    
    im_rgb = im2uint8(im_rgb);
end
