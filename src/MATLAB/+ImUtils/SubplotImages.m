function SubplotImages(ims,titles)

if (~exist('titles','var'))
    titles = {};
end
    figure
    n = ceil(sqrt(length(ims)));
    m = round(sqrt(length(ims)));
    for i=1:length(ims)
        subplot(m,n,i)
        ImUtils.ThreeD.ShowMaxImage(ims{i});
        if (~isempty(titles))
            title(titles{i});
        end
    end
end
