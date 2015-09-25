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

[im,imD] = MicroscopeData.ReadMicroscopeData(imDir, imName);
    
for i=1:length(imD)
   if (~exist(fullfile(outDir,imD{i}.DatasetName),'dir')  || overwrite)
       MicroscopeData.TiffWriter(im{i},fullfile(outDir,imD{i}.DatasetName),imD{i},[],[],[],quiet);
   end
end
end

