function [ factors, unmixFactors ] = unmixDir(showPlots, removeChannels)
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

% [FileName,PathName,~] = uigetfile('*.txt','Select List File','list.txt');
% 
% if FileName~=0
%     fHand = fopen(fullfile(PathName,FileName),'rt');
%     files = textscan(fHand,'%s','delimiter','\n');
%     fclose(fHand);
%     
%     folderList = [char(fullfile(PathName,files{1,1}(1),files{1,1}(1))), '.txt'];
%     for i=2:length(files{1,1})
%         folderList = [folderList; {fullfile(PathName,char(files{1,1}(i)),[char(files{1,1}(1)),'.txt'])}];
%     end
% else
%     warning('No files to unmix!');
%     return
% end

PathName = uigetdir();
txtFiles = dir(fullfile(PathName,'*.txt'));

[numDevices,mem] = CudaMex('DeviceCount');

[imMixedTest, imData] = tiffReader(fullfile(PathName,txtFiles(1).name));
w = whos('imMixedTest');
numImOnDevice = floor(max([mem.available]/(numel(imMixedTest)*(32 + 8)),1)*2); 

clear('imMixedTest');

maxWorkers = sum(numImOnDevice(:));
workersDevice = zeros(1,maxWorkers);
n = 1;
for i=1:numDevices
    for j=1:numImOnDevice(i)
        workersDevice(n) = i;
        n = n + 1;
    end
end

% poolObj = gcp('nocreate');
% if (~isempty(poolObj))
%     oldWorkers = poolObj.NumWorkers;
%     if (oldWorkers~=maxWorkers)
%         delete(poolObj);
%         parpool(maxWorkers);
%     end
% else
%     oldWorkers = 0;
%     parpool(maxWorkers);
% end

tic
%spmd
%     for i=labindex:numlabs:length(folderList)
   for i=1:length(txtFiles)
        %%read in a mixed image
        tic
        [imMixed, imageData] = tiffReader(fullfile(PathName,txtFiles(i).name),[],[],[],[],0,1);
        if (isempty(imMixed))
            warning('Could not read "%s"!',fullfile(PathName,txtFiles(i).name));
            continue
        end
        
        %% unmix
        cudaOut = CudaMex('LinearUnmixing',imMixed,unmixFactors,workersDevice(labindex));
        
        cudaOut(cudaOut<0) = 0;
        
        for c=1:imageData.NumberOfChannels
            mixedChan = imMixed(:,:,:,c,:);
            maxMixedVal = max(mixedChan(:));
            unMixedChan = cudaOut(:,:,:,c,:);
            maxUnMixedVal = max(unMixedChan(:));
            difFac = single(maxMixedVal) / maxUnMixedVal;
            cudaOut(:,:,:,c,:) =  cudaOut(:,:,:,c,:) * difFac / single(maxMixedVal);
        end
        
        tiffWriter(imageConvertNorm(cudaOut,w.class,0),...
            fullfile(imageData.imageDir,'..','_unmixed',imageData.DatasetName,imageData.DatasetName),imageData,...
            [],[],[],1);
        
        fprintf('Finished %s in %s\n',imageData.DatasetName,printTime(toc));
    end
% end
system(sprintf('dir /B /ON "%s" > "%s"',fullfile(imData.imageDir,'..','_unmixed','.'),fullfile(imData.imageDir,'..','_unmixed','list.txt')));
tm = toc;
fprintf('Unmixing took %s for %d images, avg %s\n',printTime(tm),length(folderList),printTime(tm/length(folderList)));

% if (oldWorkers~=maxWorkers)
%     delete(gcp);
%     if (oldWorkers>0)
%         parpool(oldWorkers);
%     end
% end
end

