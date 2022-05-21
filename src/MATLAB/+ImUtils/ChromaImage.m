function [chroma_im] = ChromaImage(im, background_white)
    background_val = 0;
    if exist("background_white", 'var') && ~isempty(background_white) && background_white
        background_val = 1;
    end

    im = single(im);

    color_2d = ndims(im)==3;
    if color_2d
        im_sum = sum(im,3);
    else
        im_sum = sum(im,4);
    end
    
    chroma_im = im ./ im_sum;

    if color_2d
        im_med = median(chroma_im, 3);
        lower_bound = 1/3 - 0.01;
        upper_bound = 1/3 + 0.01;
    else
        im_med = median(chroma_im, 4);
        lower_bound = 1/size(im,4) - 0.01;
        upper_bound = 1/size(im,4) + 0.01;
    end

    im_mask = im_med > lower_bound & im_med < upper_bound;

    if color_2d
        chroma_im(repmat(im_mask, [1,1,3])) = background_val;
    else
        chroma_im(repmat(im_mask, [1, 1, 1, size(im,4), 1])) = background_val;
    end
end
