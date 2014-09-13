function [ factors, unmixFactors ] = unmixDir(showPlots, folderList)
%UNMIXDIR Summary of this function goes here
%   Detailed explanation goes here

%% get factors
if ~exist('showPlots','var') || isempty(showPlots)
    showPlots = 0;
end

[ factors, unmixFactors ] = linearUnmixSignals(showPlots);
if isempty(factors)
    warning('Mixed factors are empty!');
    toc
    return
end

if (~exist('folderList','var') || isempty(folderList))
    [FileName,PathName,~] = uigetfile('*.txt');
    
    if FileName~=0
        fHand = fopen(fullfile(PathName,FileName));
        files = textscan(fHand,'%s','delimiter','\n');
        fclose(fHand);
        
        folderList = fullfile(PathName,files{1,1}(1));
        for i=2:length(files{1,1})
            folderList = [folderList; {char(fullfile(PathName,files{1,1}(i)))}];
        end
    end
else
    warning('No files to unmix!');
    return
end

tic
for i=1:length(folderList)
    %%read in a mixed image
    [imMixed, imageData] = tiffReader([],[],[],[],folderList{i});
    
    %% unmix
    cudaOut = CudaMex_d('LinearUnmixing',imMixed,unmixFactors);
    
    w = whos('imMixed');

    tiffWriter(imageConvert(cudaOut,w.class),...
        fullfile(sprintf('%s%s',imageData.imageDir,'_unmixed'),imageData.DatasetName),imageData);
end
toc
end

