% ConvertOldH5toNew( rootDir, fileName )
function ConvertOldH5toNew( rootDir, fileName )
    if (~exist('fileName','var') || isempty(fileName))
        dList = dir(fullfile(rootDir,'*.h5'));
        for i=1:length(dList)
            MicroscopeData.Sandbox.ConvertOldH5toNew(rootDir,dList(i).name);
        end
        dirList = dir(rootDir);
        for i=1:length(dirList)
            if (dirList(i).isdir && ~strcmpi(dirList(i).name,'.') && ~strcmpi(dirList(i).name,'..'))
                MicroscopeData.Sandbox.ConvertOldH5toNew(fullfile(rootDir,dirList(i).name));
            end
        end
    else
        [~,datasetName,ext] = fileparts(fileName);
        if (~strcmpi('.h5',ext))
            return
        end
        
        h5Path = fullfile(rootDir,fileName);
        jsonPath = fullfile(rootDir,[datasetName,'.json']);
        fprintf('%s...',jsonPath);
        if (exist(h5Path,'file'))
            info = h5info(h5Path);
            if (isempty(info.Groups) && ~isempty(info.Datasets) && any(strcmpi('Data',{info.Datasets.Name})))
                imD = MicroscopeData.ReadMetadataFile(jsonPath);
                im = h5read(h5Path,'/Data', [1 1 1 1 1], [Utils.SwapXY_RC(imD.Dimensions) imD.NumberOfChannels imD.NumberOfFrames]);
                delete(h5Path);
                fprintf('deleted\n');
                MicroscopeData.WriterH5(im,imD.imageDir,'imageData',imD,'verbose',true);
            else
                fprintf('skipped\n');
            end
        end
    end
end

