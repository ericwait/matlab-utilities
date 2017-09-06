function ConvertDir(outType,readPath,outDir,overwrite,includeTiff,cleanName)
%convertDir Recursivly converts microscope data to tiff files plus metadata
%           text
%   Walks through the dirPath and converts all microscope data found in the
%   root dir or any subdirectories.  The converted tiffs are stored in
%   outDir under outDir/filename/capturename/capturename_c%02d_t%04d_z%04d.tif
%   Set overwrite to 1 to replace existing file. Empty or any other value
%   will not overwrite current directories.

if (~exist('readPath','var') || isempty(readPath))
    readPath = uigetdir('.','Choose source folder');
    if (readPath==0), return, end
end
[~,name,~]=fileparts(readPath);
if (~exist('outDir','var') || isempty(outDir))
    outDir = uigetdir(readPath,['Choose destination folder for source: ' name]);
    if (outDir==0), return, end
end

if (~exist('outType','var') || isempty(outType))
    outType = 'klb';
end

if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = 0;
end

if (~exist('includeTiff','var') || isempty(includeTiff))
    includeTiff = false;
end
if (~exist('cleanName','var'))
    cleanName = true;
end

recursiveConvertDir(outType,readPath,outDir,'','',overwrite,includeTiff,cleanName);

system(sprintf('dir "%s" /B /O:N /A:D > "%s\\list.txt"',outDir,outDir));
end

function recursiveConvertDir(outType,rootDir,outDir, subDir,outSub, overwrite,includeTiff,cleanName)
    folderList = dir(fullfile(rootDir,subDir));
    
    bInvalidName = arrayfun(@(x)(strncmpi(x.name,'.',1) || strncmpi(x.name,'..',2)), folderList);
    bValidDir = ~bInvalidName & (vertcat(folderList.isdir) > 0);
    
    dirList = folderList(bValidDir);
    fileList = folderList(vertcat(folderList.isdir) == 0);
    
    fileNames = {fileList.name}.';
    [bCanExport,guessType] = MicroscopeData.Original.CanExportFormat(fileNames);
    
    guessType = guessType(bCanExport);
    fileNames = fileNames(bCanExport);
    
    for i=1:length(fileNames)
        [~,~,fext] = fileparts(fileNames{i});
        if ( any(strcmpi(fext,{'.tif','.tiff'})) && ~includeTiff )
            continue;
        end
        

        fprintf('Export %s (%s) ...\n',fullfile(rootDir,subDir,fileNames{i}),guessType{i});
        tic
        MicroscopeData.Original.ConvertData(fullfile(rootDir,subDir),fileNames{i},fullfile(outDir,outSub),outType,overwrite,false,cleanName);
        fprintf('took %s\n\n',Utils.PrintTime(toc));
    end
    
    for i=1:length(dirList)
        folderName = dirList(i).name;
        newSubDir = fullfile(subDir, folderName);
        
        if ( cleanName )
            folderName = MicroscopeData.Helper.SanitizeString(folderName);
        end
        newOutSub = fullfile(outSub, folderName);
        
        recursiveConvertDir(outType,rootDir,outDir, newSubDir,newOutSub,overwrite,includeTiff,cleanName)
    end
end
