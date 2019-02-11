function KLB_(im,datasetName,outDir,pixelPhysicalSize,chanList,timeRange,filePerT,filePerC,verbose)
    bytes = MicroscopeData.Helper.GetBytesPerVoxel(im);
    
%     im = permute(im,[2,1,3,4,5]);

    blockSize_xyzct = [64,64,size(im,3),1,1];
    blockMem = prod(blockSize_xyzct)*bytes;
    blockSize_xyzct(5) = max(1,floor((1024^2)/blockMem)); % try to get close to 1MB block size

    myCluster = parcluster('local');
    threads = myCluster.NumWorkers;

    fileName = fullfile(outDir,datasetName);
    prgs = Utils.CmdlnProgress(size(im,4)*size(im,5),true);
    if (filePerT)
        if (filePerC)
            for t=1:length(timeRange(1):timeRange(2))
                for c=1:length(chanList)
                    fileNameCT = sprintf('%s_c%d_t%04d',fileName,chanList(c),(t-1)+timeRange(1));
                    MicroscopeData.KLB.writeKLBstack(im(:,:,:,c,t), [fileNameCT,'.klb'], threads, [pixelPhysicalSize,1,1], blockSize_xyzct);
                    if (verbose)
                        prgs.PrintProgress(c+(t-1)*length(chanList));
                    end
                end
            end
        else
            for t=1:length(timeRange(1):timeRange(2))
                fileNameT = sprintf('%s_t%04d',fileName,(t-1)+timeRange(1));
                MicroscopeData.KLB.writeKLBstack(im(:,:,:,:,t), [fileNameT,'.klb'], threads, [pixelPhysicalSize,1,1], blockSize_xyzct);
                if (verbose)
                    prgs.PrintProgress(t*length(chanList));
                end
            end
        end
    elseif (filePerC)
        for c=1:length(chanList)
            fileNameC = sprintf('%s_c%d',fileName,chanList(c));
            MicroscopeData.KLB.writeKLBstack(squeeze(im(:,:,:,c,:)), [fileNameC,'.klb'], threads, [pixelPhysicalSize,1,1], blockSize_xyzct);
            if (verbose)
                prgs.PrintProgress(c*length(timeRange(1):timeRange(2)));
            end
        end
    else
        MicroscopeData.KLB.writeKLBstack(im, [fileName,'.klb'], threads, [pixelPhysicalSize,1,1], blockSize_xyzct);
    end
    
    if (verbose)
        prgs.ClearProgress(true);
        f = dir(fullfile(outDir,[datasetName,'*.klb']));
        fBytes = sum([f.bytes]);
        fprintf('Wrote %s %.0fMB-->%.0fMB\n', datasetName, (bytes*numel(im))/(1024*1024),fBytes/1024/1024);
    end
end