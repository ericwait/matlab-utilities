function imBW = OtsuSeg5D(im,alpha,prgStr,prntTotalTime)
if (~exist('prgStr','var'))
    prgStr = '';
end
if (~exist('prntTotalTime','var'))
    prntTotalTime = false;
end

imBW = false(size(im));

nChan = size(im,4);
nFrms = size(im,5);

prgs = Utils.CmdlnProgress(nChan*nFrms,true,prgStr);
for t=1:nFrms
    for c=1:nChan
        curIm = im(:,:,:,c,t);
        level = graythresh(curIm(curIm>0));
        imBW(:,:,:,c,t) = curIm > level*alpha;
        
        prgs.PrintProgress((t-1)*nChan + c);
    end
end
prgs.ClearProgress(prntTotalTime);
end