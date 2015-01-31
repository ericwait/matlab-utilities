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
    [FileName,PathName,~] = uigetfile('*.txt','Select List File','list.txt');
    
    if FileName~=0
        fHand = fopen(fullfile(PathName,FileName),'rt');
        files = textscan(fHand,'%s','delimiter','\n');
        fclose(fHand);
        
        folderList = [char(fullfile(PathName,files{1,1}(1),files{1,1}(1))), '.txt'];
        for i=2:length(files{1,1})
            folderList = [folderList; {fullfile(PathName,char(files{1,1}(i)),[char(files{1,1}(1)),'.txt'])}];
        end
    end
else
    warning('No files to unmix!');
    return
end

[imMixedTest, ~] = tiffReader(fullfile(PathName,files{1}{1},[files{1}{1},'.txt']));
w = whos('imMixedTest');
clear('imMixedTest');

delete(gcp('nocreate'));

parpool(4)

tic
spmd
    for i=labindex:numlabs:length(folderList)
        %%read in a mixed image
        [imMixed, imageData] = tiffReader(fullfile(PathName,files{1}{i},[files{1}{i},'.txt']),[],[],[],[],[],1);
        
        %% unmix
        cudaOut = CudaMex('LinearUnmixing',imMixed,unmixFactors);
        
        tiffWriter(imageConvertNorm(cudaOut,w.class,0),...
            fullfile(imageData.imageDir,'..',[imageData.DatasetName,'_unmixed'],imageData.DatasetName),imageData);
    end
end
tm = toc;
fprintf('Unmixing took %s for %d images, avg %s\n',printTime(tm),length(folderList),printTime(tm/length(folderList)));

delete(gcp);
end

