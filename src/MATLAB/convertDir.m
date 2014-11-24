function convertDir(dirPath,outDir,overwrite,includeTif)
%convertDir Recursivly converts microscope data to tiff files plus metadata
%           text
%   Walks through the dirPath and converts all microscope data found in the
%   root dir or any subdirectories.  The converted tiffs are stored in
%   outDir under outDir/filename/capturename/capturename_c%02d_t%04d_z%04d.tif
%   Set overwrite to 1 to replace existing file. Empty or any other value
%   will not overwrite current directories.

if (~exist('dirPath','var') || isempty(dirPath))
    dirPath = uigetdir();
    if (dirPath==0), return, end
end
if (~exist('outDir','var') || isempty(outDir))
    outDir = uigetdir();
    if (outDir==0), return, end
end
if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = 0;
end

if (~exist('includeTif','var') || isempty(includeTif))
    includeTif = 0;
end

folderList = dir(dirPath);
for i=1:length(folderList)
    if (strcmp(folderList(i).name,'.') || strcmp(folderList(i).name,'..')), continue, end
    
    if (folderList(i).isdir)
        convertDir(fullfile(dirPath,folderList(i).name),outDir,overwrite);
    else
        ind = strfind(folderList(i).name,'.');
        exten = folderList(i).name(ind(end)+1:end);
        if (strcmpi(exten,'lif') || strcmpi(exten,'lsm') || strcmpi(exten,'zvi') || strcmpi(exten,'nd2') ||...
                strcmpi(exten,'oif') || (strcmpi(exten,'tif') && includeTif))
            fprintf('%s ...\n',fullfile(dirPath,folderList(i).name));
            tic
            readMicroscopeData(dirPath,folderList(i).name,outDir,overwrite);
            fprintf('took %s\n\n',printTime(toc));
        end
    end
end
end
