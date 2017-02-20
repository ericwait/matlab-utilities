
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
parentFolder = MicroscopeData.Web.findParentFolder(inPath,outPath);
imOutPath = fullfile(outPath, parentFolder, imData.DatasetName);

if(~exist(outPath, 'dir'));    mkdir(outPath);   end
if(~exist(fullfile(outPath, parentFolder), 'dir'));    mkdir(fullfile(outPath, parentFolder)); end
%%if(exist(fullfile(outPath, parentFolder, imData.DatasetName), 'dir'));     rmdir(fullfile(outPath, parentFolder, imData.DatasetName),'s'); end
if(~exist(fullfile(outPath, parentFolder, imData.DatasetName), 'dir'));     mkdir(fullfile(outPath, parentFolder, imData.DatasetName)); end

% Export Html
MicroscopeData.Web.ExportHTML(outPath, parentFolder, imData.DatasetName);
% Export Hulls
imData = MicroscopeData.Web.ExportHullJSON(imData,inPath,imOutPath);
% Export Metadata
MicroscopeData.CreateMetadata(imOutPath, imData, parentFolder);
%% Export Tiles in Tree Structure  
MicroscopeData.Web.MakeTiles(imData,imOutPath);
MicroscopeData.Web.BlendTiles(imData,imOutPath);
fprintf('Atlas exported to %s\n', imOutPath);
%% Export Thumbnail
MicroscopeData.Web.makeThumbnail(imData,imOutPath);
%% Update Json List of Experiments 
%%MicroscopeData.Web.createDataList(outPath);
end


 