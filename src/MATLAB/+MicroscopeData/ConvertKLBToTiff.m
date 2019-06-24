function ConvertKLBToTiff(klbDir)
    dList = dir(fullfile(klbDir,'*.klb*'));
    outDir = fullfile(klbDir,'tif');
    if (~exist(outDir,'dir'))
        mkdir(outDir);
    end
    
    prgs = Utils.CmdlnProgress(length(dList),true,'Converting KLB to tif',true);
    for i=1:length(dList)
        try
            tempIm = MicroscopeData.KLB.readKLBstack(fullfile(dList(i).folder,dList(i).name));
        catch err
            continue
        end
        [~,fName] = fileparts(dList(i).name);
        if (ndims(tempIm)>3)
            error('Images with more than three dimensions are currently not supported')
        end
        MicroscopeData.Write3Dtif(tempIm,fName,outDir);
        
        prgs.PrintProgress(i);
    end
    prgs.ClearProgress(true);
    
    dList = dir(fullfile(klbDir,'*.json'));
    if (~isempty(dList))
        for i=1:length(dList)
            copyfile(fullfile(dList(i).folder,dList(i).name),fullfile(outDir,dList(i).name));
        end
    end
end