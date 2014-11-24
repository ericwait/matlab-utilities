function [ factors, unmixFactors ] = unmixDir(showPlots, folderList, removeChannels)
%UNMIXDIR Summary of this function goes here
%   Detailed explanation goes here

%% get factors
if ~exist('showPlots','var') || isempty(showPlots)
    showPlots = 0;
end
if ~exist('removeChannels')
    removeChannels = [];
end

[ factors, unmixFactors ] = linearUnmixSignals(showPlots,removeChannels);
if isempty(factors)
    warning('Mixed factors are empty!');
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

[imMixedTest, ~] = tiffReader([],[],[],[],folderList{1});
w = whos('imMixedTest');
clear('imMixedTest');

delete(gcp('nocreate'));

parpool(2)

tic
spmd
    for i=1:numlabs:length(folderList)
        %%read in a mixed image
        [imMixed, imageData] = tiffReader([],[],[],[],folderList{i});
        
        %% unmix
        cudaOut = CudaMex('LinearUnmixing',imMixed,unmixFactors);
        
        tiffWriter(imageConvert(cudaOut,w.class),...
            fullfile(sprintf('%s%s',imageData.imageDir,'_unmixed'),imageData.DatasetName),imageData);
    end
end
tm = toc;
fprintf('Unmixing took %s for %d images, avg %s\n',printTime(tm),length(folderList),printTime(tm/length(folderList)));

delete(gcp);
end

