function ConvertTiffToKLB(tifDir)
    dList = dir(fullfile(tifDir,'*.tif*'));
    outDir = fullfile(tifDir,'klb');
    if (~exist(outDir,'dir'))
        mkdir(outDir);
    end
    
    for i=1:length(dList)
        try
            tempIm = MicroscopeData.LoadTif(fullfile(tifDir,dList(i).name));
        catch err
            continue
        end
        MicroscopeData.KLB.WriteBasicKLB(tempIm,outDir,dList(i).name);
    end
end
