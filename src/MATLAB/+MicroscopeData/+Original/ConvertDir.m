function ConvertDir(readPath,outDir,subDirsIn,overwrite,includeTiff,cleanName)
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
    outDir = uigetdir('.',['Choose destination folder for source: ' name]);
    if (outDir==0), return, end
end
if (~exist('subDirsIn','var'))
    subDirsIn = '.';
end

if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = 0;
end

if (~exist('includeTiff','var') || isempty(includeTiff))
    includeTiff = false;
end
if (~exist('cleanName','var'))
    cleanName = [];
end

folderList = dir(readPath);
for i=1:length(folderList)
    if (strcmp(folderList(i).name,'.') || strcmp(folderList(i).name,'..')), continue, end
    
    if (folderList(i).isdir)
        subDirs = fullfile(subDirsIn,folderList(i).name);
        MicroscopeData.Original.ConvertDir(fullfile(readPath,folderList(i).name),outDir,subDirs,overwrite,includeTiff);
    else
        [~,~,exten] = fileparts(folderList(i).name);
        if (strcmpi(exten,'.lif') || strcmpi(exten,'.lsm') || strcmpi(exten,'.zvi') || strcmpi(exten,'.nd2') ||...
                strcmpi(exten,'.oif') || strcmpi(exten,'.czi') || strcmpi(exten,'.stk') || (strcmpi(exten,'.tif') && includeTiff))
            fprintf('%s ...\n',fullfile(readPath,folderList(i).name));
            tic
            MicroscopeData.Original.Convert2Tiffs(readPath,folderList(i).name,fullfile(outDir,subDirsIn),overwrite,cleanName);
            fprintf('took %s\n\n',Utils.PrintTime(toc));
        end
    end
end

system(sprintf('dir "%s" /B /O:N /A:D > "%s\\list.txt"',outDir,outDir));
end
