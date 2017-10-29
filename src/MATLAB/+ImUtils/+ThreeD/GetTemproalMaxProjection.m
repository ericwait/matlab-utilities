function imMax = GetTemproalMaxProjection(im,projectAxis)
    if (~exist('projectAxis','var') || isempty(projectAxis))
        projectAxis = 3;
    end

    imTMax = max(im,[],5);
    imMax = max(imTMax,[],projectAxis);
    
    imMax = squeeze(imMax);
end
