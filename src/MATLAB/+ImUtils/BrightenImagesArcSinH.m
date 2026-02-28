function imBright = BrightenImagesArcSinH(im,softnessFactor,outType,verbose)
   if (~exist('outType','var') || isempty(outType))
        outType = class(im);
   end
    if (~exist('verbose','var') || isempty(verbose))
        verbose = false;
    end

    imBright = zeros(size(im), outType);
    [~,~,~,clss] = Utils.GetClassBits(im, false);
    
    if (strcmp(clss,'logical'))
        imBright = ImUtils.ConvertType(im, outType);
        return
    end

    im = single(ImUtils.ConvertType(im, 'uint16', false));

    prgs = Utils.CmdlnProgress(size(im,5)*size(im,4),true,'Brightening images for display'); 
    for t=1:size(im,5)
        for c=1:size(im,4)
            curIm = im(:,:,:,c,t) * softnessFactor;
            curIm = asinh(curIm);

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
