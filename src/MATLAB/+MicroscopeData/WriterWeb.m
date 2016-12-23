%% This function creates CloneView3D multiresolution atlas from smoothed montage images
%   @inPath - the input image path, for example:\\bioimagefs\Process\Images
%              \Temple\3d\SVZ\Montage\Deep\Itga9 kd4(J2) Deep Labels 8-13-13
%              Take2\20x_Montage_wDelta\Smoothed
%	@outPath - the output path, for example: B:\javascript\experiments
%   @Llist - the desired detail levels, for example, we want
%       to create 2-5 LoD( level of detail), set Llist = [2:5]
%   example:
%       inPath = '\\bioimagefs\Process\Images\Temple\3d\SVZ\Montage\Deep\Deep Panel Feb2016 DAPI Mash1-647 Dcx-488 ki67-514 Laminin-Cy3 GFAP-594\18mF1 DeepPanel 10x01\normalized';
%       outPath = [inPath, '\CV3d'];
%       createMRTexture(0:4, inPath, outPath);

function [imOutPath] = WriterWeb(im,imDataOriginal, outPath, Llist)


if (~exist('im','var') || isempty(im))
[im,imDataOriginal] = MicroscopeData.Reader('verbose',true,'normalize',true);
end

if (~exist('Llist','var') || isempty(Llist))
    Llist = 0;
end

if(~exist('outPath','var') || isempty(outPath))
    outPath = uigetdir('','Choose the Atlas output Directory (Experiments Folder)');
end

[imData] = MicroscopeData.Web.FixMeta(imDataOriginal);


%% Make Folders 
inPath = imData.imageDir;
parentFolder = findParentFolder(inPath);

if(~exist(outPath, 'dir'));    mkdir(outPath);   end

if(~exist(fullfile(outPath, parentFolder), 'dir'));    mkdir(fullfile(outPath, parentFolder)); end

if(~exist(fullfile(outPath, parentFolder, imData.DatasetName), 'dir'));     mkdir(fullfile(outPath, parentFolder, imData.DatasetName)); end

%% Export Html
htmlOutPath = fullfile(outPath, parentFolder);
MicroscopeData.Web.ExportHTML(htmlOutPath, parentFolder, imData.DatasetName);
%% Export Thumbnail
imOutPath = fullfile(outPath, parentFolder, imData.DatasetName);
MicroscopeData.Web.makeThumbnail(imOutPath,im,imData);
%% Export Metameta 
MicroscopeData.CreateMetadata(imOutPath, imData);
%% Export Tiles in Tree Structure
MicroscopeData.Web.MakeTiles(im,imData,imOutPath,Llist);
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
