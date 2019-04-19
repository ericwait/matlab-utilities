function imBright = BrightenImages(im,outType,prctSaturated,backgroundLevel,verbose)
    if (~exist('outType','var') || isempty(outType))
        outType = class(im);
    end
    if (~exist('prctSaturated','var') || isempty(prctSaturated))
        prctSaturated = 0.005;
    end
    if (~exist('backgroundLevel','var') || isempty(backgroundLevel))
        backgroundLevel = 0;
    end
    if (~exist('verbose','var') || isempty(verbose))
        verbose = false;
    end

    imBright = zeros(size(im),outType);
    [bits,~,~,clss] = Utils.GetClassBits(im,false);
    bits = min(bits,16);
    numBins = 2^bits;
    
    if (strcmp(clss,'logical'))
        imBright = ImUtils.ConvertType(im,outType);
        return
    end

    prgs = Utils.CmdlnProgress(size(im,5)*size(im,4),true,'Brightening images for display'); 
    for t=1:size(im,5)
        for c=1:size(im,4)
            curIm = im(:,:,:,c,t)-backgroundLevel;
            subVal = backgroundLevel/double(max(curIm(:)));
            curIm = mat2gray(curIm) - subVal;
            curIm(curIm<0) = 0;
            [n,edge] = histcounts(curIm(:),numBins);
            dis = cumsum(n,'reverse')./numel(curIm);
            maxBin = find(dis(2:end)<prctSaturated,1,'first')+1;
            if (isempty(maxBin))
                maxBin = length(edge);
            end
%             minVal = edge(1)
%             maxVal = edge(maxBin)-minVal
%             curIm = curIm - minVal;
            curIm = curIm./edge(maxBin);
            curIm(curIm>1) = 1;

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
