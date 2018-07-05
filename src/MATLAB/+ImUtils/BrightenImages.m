function imBright = BrightenImages(im,prctInclude,verbose)
    if (~exist('prctInclude','var') || isempty(prctInclude))
        prctInclude = 0.999;
    end
    if (~exist('verbose','var') || isempty(verbose))
        verbose = false;
    end

    imBright = zeros(size(im),'uint8');
    [bits,~,~,clss] = Utils.GetClassBits(im,false);
    bits = min(bits,16);
    numBins = 2^bits;

    prgs = Utils.CmdlnProgress(size(im,5)*size(im,4),true,'Brightening images for display'); 
    for t=1:size(im,5)
        for c=1:size(im,4)
            curIm = im2single(im(:,:,:,c,t));
            [n,edge] = histcounts(curIm(:),numBins);
            dis = cumsum(n)./numel(curIm);
            maxBin = find(dis>prctInclude,1,'first');
            curIm = curIm./edge(maxBin);
            curIm(curIm>1) = 1;

            imBright(:,:,:,c,t) = ImUtils.ConvertType(curIm,'uint8',true);
        end
        if (verbose)
            prgs.PrintProgress(t*size(im,4));
        end
    end
    if (verbose)
        prgs.ClearProgress(true);
    end
end
