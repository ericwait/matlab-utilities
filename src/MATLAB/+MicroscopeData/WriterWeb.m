
function [imOutPath] = WriterWeb(imDataOriginal, outPath, Llist)

if (~exist('Llist','var') || isempty(Llist))
    Llist = 0;
end

if(~exist('outPath','var') || isempty(outPath))
    outPath = uigetdir('','Choose the Atlas output Directory (Experiments Folder)');
end

if (~exist('imDataOriginal','var') || isempty(imDataOriginal))
[imDataOriginal] = MicroscopeData.ReadMetadata('verbose',true);
end
[imData] = MicroscopeData.Web.FixMeta(imDataOriginal);


%% Make Folder Structure
inPath = imData.imageDir;
parentFolder = findParentFolder(inPath);
imOutPath = fullfile(outPath, parentFolder, imData.DatasetName);

if(~exist(outPath, 'dir'));    mkdir(outPath);   end

if(~exist(fullfile(outPath, parentFolder), 'dir'));    mkdir(fullfile(outPath, parentFolder)); end

if(~exist(fullfile(outPath, parentFolder, imData.DatasetName), 'dir'));     mkdir(fullfile(outPath, parentFolder, imData.DatasetName)); end

%% Export Html
htmlOutPath = fullfile(outPath, parentFolder);
MicroscopeData.Web.ExportHTML(htmlOutPath, parentFolder, imData.DatasetName);
%% Export Metameta 
MicroscopeData.CreateMetadata(imOutPath, imData);
%% Export Tiles in Tree Structure
MicroscopeData.Web.MakeTiles(imData,imOutPath,Llist);
fprintf('Atlas exported to %s\n', imOutPath);
%% Update Json List of Experiments 
MicroscopeData.Web.createDataList(outPath);
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
