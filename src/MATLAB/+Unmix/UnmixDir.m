function [ factors, unmixFactors ] = UnmixDir(showPlots, removeChannels, factors, unmixFactors)
%UNMIXDIR Summary of this function goes here
%   Detailed explanation goes here

%% get factors
if ~exist('showPlots','var') || isempty(showPlots)
    showPlots = 0;
end
if ~exist('removeChannels','var')
    removeChannels = [];
end

if (~exist('factors','var') || ~exist('unmixFactors','var') || isempty(factors) || isempty(unmixFactors))
    [ factors, unmixFactors ] = Unmix.LinearUnmixSignals(showPlots,removeChannels);
end
if isempty(factors)
    warning('Mixed factors are empty!');
    return
end

imageDatasets = Registration.GetMontageSubMeta();

[numDevices,mem] = Cuda.Mex('DeviceCount');
typ = MicroscopeData.GetImageClass(imageDatasets(1));
switch typ
    case 'uint8'
        multiplier = 8;
    case 'uint16'
        multiplier = 16;
    case 'int16'
        multiplier = 16;
    case 'uint32'
        multiplier = 32;
    case 'int32'
        multiplier = 32;
    case 'single'
        multiplier = 32;
    case 'double'
        multiplier = 64;
    case 'logical'
        multiplier = 8;
    otherwise
        multiplier = 0;
end

numImOnDevice = floor(max([mem.available]/(prod(imageDatasets(1).Dimensions)*multiplier),1)); 
maxWorkers = sum(numImOnDevice(:));
workersDevice = zeros(1,maxWorkers);
n = 1;
for i=1:numDevices
    for j=1:numImOnDevice(i)
        workersDevice(n) = i;
        n = n + 1;
    end
end

poolObj = gcp('nocreate');
if (~isempty(poolObj))
    oldWorkers = poolObj.NumWorkers;
    if (oldWorkers~=maxWorkers)
        delete(poolObj);
        parpool(maxWorkers);
    end
else
    oldWorkers = 0;
    parpool(maxWorkers);
end

tic
spmd
    for i=labindex:numlabs:length(imageDatasets)
  % for i=1:length(imageDatasets)
        %%read in a mixed image
        tic
        [imMixed, imageData] = MicroscopeData.Reader(imageDatasets(i),[],[],[],[],0,1);
        if (isempty(imMixed))
            warning('Could not read "%s"!',fullfile(PathName,imageDatasets(i).DatasetName));
            continue
        end
        [~,~,maxVal] = Utils.GetClassBits(imMixed);
        
        if (max(imMixed(:)) > 0.28*maxVal)
            unmixedIm  = Cuda.Unmix.Image( imMixed, imageData, unmixFactors, false,2);
        else
            unmixedIm = imMixed;
        end
        
        MicroscopeData.Writer(unmixedIm,fullfile(imageDatasets(i).imageDir,'..','_unmixed',imageDatasets(i).DatasetName),imageDatasets(i),...
            [],[],[],1);
        
        fprintf('Finished %s in %s\n',imageDatasets(i).DatasetName,Utils.PrintTime(toc));
    end
end
system(sprintf('dir /B /O:N /A:D "%s" > "%s"',fullfile(imageDatasets(1).imageDir,'..','_unmixed','.'),fullfile(imageDatasets(1).imageDir,'..','_unmixed','list.txt')));
tm = toc;
fprintf('Unmixing took %s for %d images, avg %s\n',...
    Utils.PrintTime(tm),length(imageDatasets),Utils.PrintTime(tm/length(imageDatasets)));

if (oldWorkers~=maxWorkers)
    delete(gcp);
    if (oldWorkers>0)
        parpool(oldWorkers);
    end
end
end

