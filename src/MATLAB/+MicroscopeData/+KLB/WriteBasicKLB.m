function WriteBasicKLB(im,filePath,fileName)

    [morePath,fileName] = fileparts(fileName);
    
    bytes = Utils.GetClassBits(im)/8;
    blockSize_xyzct = [64,64,size(im,3),1,1];
    blockMem = prod(blockSize_xyzct)*bytes;
    blockSize_xyzct(5) = max(1,floor((1024^2)/blockMem)); % try to get close to 1MB block size
    
    myCluster = parcluster('local');
    threads = myCluster.NumWorkers;
    
    if (~exist(filePath,'dir'))
        [status,msg] = mkdir(filePath);
        if (status==1 && ~isempty(msg))
            warning(msg);
            return
        end
    end
    
    outputName = fullfile(filePath,morePath,[fileName,'.klb']);
    MicroscopeData.KLB.writeKLBstack(im, outputName, threads, [1,1,1,1,1], blockSize_xyzct);
end
