function imH = HistoMatch(im,imD,refFrameNum)
    if (~exist('refFrameNum','var') || isempty(refFrameNum))
        refFrameNum = 1;
    end

    im = ImUtils.ConvertType(im,'single',true);
    imH = im;
    refFrame = im(:,:,:,:,refFrameNum);

    prgs = Utils.CmdlnProgress(imD.NumberOfFrames,true,'Histo matching');
    for t=1:imD.NumberOfFrames
        for c=1:imD.NumberOfChannels
            imH(:,:,:,c,t) = imhistmatchn(im(:,:,:,c,t),refFrame(:,:,:,c),256);
        end
        
        prgs.PrintProgress(t);
    end
    prgs.ClearProgress(true);
end
