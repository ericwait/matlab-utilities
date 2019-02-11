function WriteROI(pathToJson)
    [xyz_roi,timeRange] = ImUtils.ThreeD.GetRoi(pathToJson);
    
    imD = MicroscopeData.ReadMetadata(pathToJson);
    imD.Dimensions = xyz_roi(2,:)-xyz_roi(1,:)+1;
    imD.NumberOfFrames = length(timeRange(1):timeRange(2));
    imD.DatasetName = [imD.DatasetName,'_roi'];
    
    prgs = Utils.CmdlnProgress(imD.NumberOfFrames,true,'Writing ROI',true);
    parfor t=timeRange(1):timeRange(2)
        imR = MicroscopeData.Reader(pathToJson,'roi_xyz',xyz_roi,'timeRange',[t,t]);
        MicroscopeData.WriterKLB(imR,'path',fullfile(imD.imageDir,'..',imD.DatasetName),'imageData',imD,'timeRange',[t,t]);
        prgs.PrintProgress(t-timeRange(1)+1);
    end
    prgs.ClearProgress(true);
    
end
