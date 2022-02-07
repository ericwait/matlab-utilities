function imBright = BrightenImagesGamma(im,outType,gamma,backgroundLevel,verbose)
   if (~exist('outType','var') || isempty(outType))
        outType = 'uint8';
    end
    if (~exist('gamma','var') || isempty(gamma))
        gamma = 1/3;
    end
    if (~exist('backgroundLevel','var') || isempty(backgroundLevel))
        backgroundLevel = 0;
    end
    if (~exist('verbose','var') || isempty(verbose))
        verbose = false;
    end

    imBright = zeros(size(im),outType);
    [~,~,~,clss] = Utils.GetClassBits(im,false);
    
    if (strcmp(clss,'logical'))
        imBright = ImUtils.ConvertType(im,outType);
        return
    end

    prgs = Utils.CmdlnProgress(size(im,5)*size(im,4),true,'Brightening images for display'); 
    for t=1:size(im,5)
        for c=1:size(im,4)
            curIm = im(:,:,:,c,t)-backgroundLevel;
            curIm(curIm(:)<0) = 0;
            curIm = mat2gray(curIm);
            curIm = curIm.^gamma;

            imBright(:,:,:,c,t) = ImUtils.ConvertType(curIm,outType,true);
        end
        if (verbose)
            prgs.PrintProgress(t*size(im,4));
        end
    end
    if (verbose)
        prgs.ClearProgress(true);
    end
end
