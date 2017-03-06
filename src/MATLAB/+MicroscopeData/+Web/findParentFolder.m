function parentFolder = findParentFolder(inPath,OutPath)
tempPath = strsplit(inPath, '\');

parentFolder = MicroscopeData.Helper.SanitizeString(tempPath{end});
i = 1;
while(strcmp(parentFolder, '_Montage_wDelta') || strcmp(parentFolder, 'Smoothed') || strcmp(parentFolder, 'normalized'))
    i = i + 1;
    parentFolder = MicroscopeData.Helper.SanitizeString(tempPath{end-i});
end

parentFolder = combineFolders(parentFolder,OutPath);

end

function newParentFolder = combineFolders(parentFolder,OutPath)

newParentFolder = parentFolder;
if ~isempty(strfind(parentFolder,'10x1')) || ~isempty(strfind(parentFolder,'Deep'))
    
    newParentFolder = 'SVZ';
elseif ~isempty(strfind(parentFolder,'_timelapse'))
    
    newParentFolder = 'JLS';
else 
    return 
end

if exist(fullfile(OutPath,parentFolder),'dir')
movefile(fullfile(OutPath,parentFolder),fullfile(OutPath,newParentFolder))
end

end