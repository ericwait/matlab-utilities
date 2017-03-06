function [memNeeded, hasEnoughMem] = calcMemory(imData, numChannels)
    if (~exist('numChannels','var') || isempty(numChannels))
        numChannels = imData.NumberOfChannels;
    end
    hasEnoughMem = true;
    mem = memory;
%     [~, imInfo] = MicroscopeData.GetImageClass(imData);    
    memNeeded = imData.XDimension*imData.YDimension*imData.ZDimension*...
    numChannels*imData.NumberOfFrames / (1024*1024*1024);
    fprintf('Dataset size: %5.2fGB \r\n', memNeeded);
    
    memAvailable = mem.MemAvailableAllArrays/(1024*1024*1024);
    if ( memAvailable < memNeeded)
        hasEnoughMem = false;
        error('Out of memory! Need %5.2fGB more RAM \r\n', memNeeded - memAvailable);
    end
end
