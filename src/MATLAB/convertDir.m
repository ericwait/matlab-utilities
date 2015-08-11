function convertDir(dirPath,outDir,overwrite,includeTiff)
%convertDir Recursivly converts microscope data to tiff files plus metadata
%           text
%   Walks through the dirPath and converts all microscope data found in the
%   root dir or any subdirectories.  The converted tiffs are stored in
%   outDir under outDir/filename/capturename/capturename_c%02d_t%04d_z%04d.tif
%   Set overwrite to 1 to replace existing file. Empty or any other value
%   will not overwrite current directories.

if (~exist('dirPath','var') || isempty(dirPath))
    dirPath = uigetdir('.','Choose source folder');
    if (dirPath==0), return, end
end
[pathstr,name,ext]=fileparts(dirPath);
if (~exist('outDir','var') || isempty(outDir))
    outDir = uigetdir('.',['Choose destination folder for source: ' name]);
    if (outDir==0), return, end
end
if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = 0;
end

if (~exist('includeTiff','var') || isempty(includeTiff))
    includeTiff = false;
end

folderList = dir(dirPath);
for i=1:length(folderList)
    if (strcmp(folderList(i).name,'.') || strcmp(folderList(i).name,'..')), continue, end
    
    if (folderList(i).isdir)
        convertDir(fullfile(dirPath,folderList(i).name),outDir,overwrite,includeTiff);
    else
        [~,~,exten] = fileparts(folderList(i).name);
        if (strcmpi(exten,'.lif') || strcmpi(exten,'.lsm') || strcmpi(exten,'.zvi') || strcmpi(exten,'.nd2') ||...
                strcmpi(exten,'.oif') || strcmpi(exten,'.czi') || (strcmpi(exten,'.tif') && includeTiff))
            fprintf('%s ...\n',fullfile(dirPath,folderList(i).name));
            tic
            readMicroscopeData(dirPath,folderList(i).name,outDir,overwrite);
            fprintf('took %s\n\n',printTime(toc));
        end
    end
end
end
