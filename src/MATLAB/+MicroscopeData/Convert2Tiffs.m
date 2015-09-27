function [ im, imD ] = Convert2Tiffs( imDir, imName, outDir, overwrite, quiet )
%CONVERT2TIFFS Summary of this function goes here
%   Detailed explanation goes here

if (~exist('outDir','var') || isempty(outDir))
    outDir = '.';
end
if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = false;
end
if (~exist('quiet','var') || isempty(quiet))
    quiet = false;
end

if (~exist('imDir','var') || isempty(imDir))
    imDir = '.';
end

if (~exist('imName','var') || isempty(imName))
    [imName,imDir,~] = uigetfile('*.*','Choose a Microscope File to Convert');
    if (imName==0)
        warning('Nothing read');
        return
    end
end

[~,name,~] = fileparts(imName);

if (~exist(fullfile(outDir,name),'dir') || overwrite)
    
    [im,imD] = MicroscopeData.ReadMicroscopeData(imDir,imName);
    if (length(imD)>1)
        [~,datasetName,~] = fileparts(imName);
        outDir = fullfile(outDir,datasetName);
    end
    
    for i=1:length(imD)
        MicroscopeData.TiffWriter(im{i},fullfile(outDir,imD{i}.DatasetName),imD{i},[],[],[],quiet);
    end
end

end

