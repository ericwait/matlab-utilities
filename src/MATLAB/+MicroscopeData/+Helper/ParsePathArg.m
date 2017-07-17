function [outDir,datasetName] = ParsePathArg(argPath, validExt)
    outDir = '';
    datasetName = '';
    
    if ( isempty(argPath) || isempty(validExt) )
        return;
    end
    
    % If a path is specified we will use that instead of imageDir in matadata
    [outDir,chkFile,chkExt] = fileparts(argPath);
    if ( ~isempty(chkExt) && strcmpi(chkExt,validExt) )
        datasetName = chkFile;
    else
        outDir = argPath;
    end
end
