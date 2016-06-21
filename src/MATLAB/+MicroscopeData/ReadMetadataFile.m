function [imageData,jsonDir,jsonFile] = ReadMetadataFile(metadataPath)
    imageData = [];
    jsonDir = [];
    jsonFile = [];
    
    chkPath = findValidJSON(metadataPath);
    if ( isempty(chkPath) )
        return;
    end

    fileHandle = fopen(chkPath);

    jsonData = fread(fileHandle,'*char').';
    imageData = Utils.ParseJSON(jsonData);

    fclose(fileHandle);

    [rootDir,fileName] = fileparts(chkPath);
    
    jsonDir = rootDir;
    jsonFile = [fileName '.json'];

    imageData.imageDir = jsonDir;
end

function jsonPath = findValidJSON(chkPath)
    jsonPath = [];
    
    [rootDir,fileName,ext] = fileparts(chkPath);
    if ( ~isempty(ext) )
        if ( ~strcmpi(ext,'.json') )
            return;
        end
        chkPath = fullfile(rootDir,[fileName,'.json']);
    elseif (~isempty(fileName))
        % case root has a file name
        if (~exist(fullfile(rootDir,[fileName,'.json']),'file'))
            return;
        end
        chkPath = fullfile(rootDir,[fileName,'.json']);
    elseif (~isempty(rootDir))
        % case root is a path (e.g. \ terminated)
        jsonList = dir(fullfile(rootDir,'*.json'));
        if (isempty(jsonList))
            return;
        end
        chkPath = fullfile(rootDir,jsonList(1).name);
    end
    
    [rootDir,fileName,ext] = fileparts(chkPath);
    if ( ~strcmpi(ext,'.json') )
        return;
    end

    if (~exist(chkPath,'file'))
        return
    end
    
    jsonPath = chkPath;
end
