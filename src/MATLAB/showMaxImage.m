function showMaxImage(im,newFigure,maxAcross)
if (exist('newFigure','var') && ~isempty(newFigure) && newFigure==true)
    figure
end

if (~exist('maxAcross','var') || isempty(maxAcross))
    maxAcross = 3;
end

imagesc(max(im,[],maxAcross));
colormap gray
axis image
end