function howToSemaphore()
[cleanupObj,fileMap] = initCleanupData();
[bExists,bValid] = claimDataFile(fileMap, filename);
finalizeDataFile(fileMap, filename, varargin)
