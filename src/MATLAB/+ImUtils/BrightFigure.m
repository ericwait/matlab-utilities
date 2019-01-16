function BrightFigure(im,prctSat)
    if (~exist('prctSat','var'))
        prctSat = [];
    end
    
    im = ImUtils.BrightenImages(im,[],1-prctSat);
    im = max(im,[],3);
    
    figure
    imagesc(im);
    colormap gray
    axis image
end
