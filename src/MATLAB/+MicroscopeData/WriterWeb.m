
function [imOutPath] = WriterWeb(imData, outPath, Llist)

if (~exist('Llist','var') || isempty(Llist))
    Llist = 0;
end

if(~exist('outPath','var') || isempty(outPath))
    outPath = uigetdir('','Choose the Atlas output Directory (Experiments Folder)');
end

if (~exist('imData','var') || isempty(imData))
[imData] = MicroscopeData.ReadMetadata('verbose',true);
end

[imData] = MicroscopeData.Web.MakeRootMeta(imData,Llist);

%% Make Folder Structure
inPath = imData.imageDir;
parentFolder = findParentFolder(inPath);
imOutPath = fullfile(outPath, parentFolder, imData.DatasetName);

if(~exist(outPath, 'dir'));    mkdir(outPath);   end
if(~exist(fullfile(outPath, parentFolder), 'dir'));    mkdir(fullfile(outPath, parentFolder)); end
if(exist(fullfile(outPath, parentFolder, imData.DatasetName), 'dir'));     rmdir(fullfile(outPath, parentFolder, imData.DatasetName),'s'); end
mkdir(fullfile(outPath, parentFolder, imData.DatasetName));

%% Export Html
htmlOutPath = fullfile(outPath, parentFolder);
MicroscopeData.Web.ExportHTML(htmlOutPath, parentFolder, imData.DatasetName);
%% Export Metameta 
MicroscopeData.CreateMetadata(imOutPath, imData);
MicroscopeData.Web.ExportVesselJSON(imData, imOutPath,[]);
%% Export Tiles in Tree Structure
MicroscopeData.Web.MakeTiles(imData,imOutPath);
fprintf('Atlas exported to %s\n', imOutPath);
%% Update Json List of Experiments 
MicroscopeData.Web.createDataList(outPath);
%% Export Thumbnail
MicroscopeData.Web.makeThumbnail(imData,imOutPath);
end

function parentFolder = findParentFolder(inPath)
tempPath = strsplit(inPath, '\');

parentFolder = MicroscopeData.Helper.SanitizeString(tempPath{end});
i = 1;
while(strcmp(parentFolder, '_Montage_wDelta') || strcmp(parentFolder, 'Smoothed') || strcmp(parentFolder, 'normalized'))
    i = i + 1;
    parentFolder = MicroscopeData.Helper.SanitizeString(tempPath{end-i});
end

end
