
function [imOutPath] = WriterWeb(imData, Paths, Llist, bOverwrite)

ExpPath = Paths.CV5dExperimentROOT;
LEVERROOTPath = Paths.LEVERJSROOT;

%% Get Variables
if (~exist('Llist','var') || isempty(Llist)) 
    Llist = 0;
end

if(~exist('ExpPath','var') || isempty(ExpPath))
    ExpPath = uigetdir('','Choose the Atlas output Directory (Experiments Folder)');
end

if (~exist('imData','var') || isempty(imData))
    [imData] = MicroscopeData.ReadMetadata('verbose',true);
end

if (~exist('bOverwrite','var') || isempty(bOverwrite))
    bOverwrite = false;
end

[imData] = MicroscopeData.Web.MakeRootMeta(imData,Llist);

bExportText = true; 
bErase = false;

%% Make Folder Structure
[imOutPath,parentFolder] = makeCVFolders(imData,ExpPath,bErase);

%% Write Experiment Name
if (exist('ExpName','var') && ~isempty(ExpName))
    imData.ExperimentName = ExpName;
end

% Export Hulls
imDataLEVER = Segment.MakeHulls3d(imData,Paths);
% Export Html
MicroscopeData.Web.ExportHTML(ExpPath, parentFolder, imData.DatasetName);
% Export Tiles in Tree Structure
MicroscopeData.Web.BlendTiles(imDataLEVER,imOutPath,bOverwrite,bExportText);
imData.BooleanHulls = 1;
% imData = MicroscopeData.Web.ExportHullJSON(imData,imOutPath);
% Export Transfer and Hist
imData = MicroscopeData.Web.ExportTransAndHist(imData,imOutPath);
% Export Thumbnail
MicroscopeData.Web.makeThumbnail(imData,imOutPath);
% Export Metadata
MicroscopeData.CreateMetadata(imOutPath,imData, 'verbose',false);
%% Update Json List of Experiments
MicroscopeData.Web.createDataList(ExpPath);

end


function [imOutPath,parentFolder] = makeCVFolders(imData,outPath,bErase)

%% Make Folder Structure
inPath = imData.imageDir;

%% Get Parent Folder Name
if isfield(imData,'ExperimentName') && ~isempty(imData.ExperimentName)
    parentFolder = imData.ExperimentName;
else
    parentFolder = MicroscopeData.Web.findParentFolder(inPath,outPath);
end

imOutPath = fullfile(outPath, parentFolder, imData.DatasetName);

%% Make Experiment Folder
if(~exist(outPath, 'dir'))
    mkdir(outPath);
end

%% Make Parent Folder
if(~exist(fullfile(outPath, parentFolder), 'dir'))
    mkdir(fullfile(outPath, parentFolder));
else
    return
end

%% If Folders already exist erase
if exist(imOutPath, 'dir') && bErase
    rmdir(imOutPath,'s');
end

%% If Folders dont exist make them
if ~exist(imOutPath, 'dir')
    mkdir(imOutPath);
end

end

