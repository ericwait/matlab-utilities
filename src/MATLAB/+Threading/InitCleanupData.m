function [cleanupObj,fileMap] = initCleanupData()
% USAGE [cleanupObj,fileMap] = initCleanupData()
% This must be used inside a function
% DO NOT USE IN A SCRIPT!
% This will get cleaned up after the function goes out of scope
% Keep CLEANUPOBJ in the scope you want to be cleaned up.
% FILEMAP should never be used directly, used to pass into the other calls

    fileMap = containers.Map();
    cleanupObj = onCleanup(@()(cleanupIncompleteData(fileMap)));
end

function cleanupIncompleteData(fileMap)
    keySet = keys(fileMap);
    
    for i=1:length(keySet)
        if ( fileMap(keySet{i}) )
            continue;
        end
        
        delete(keySet{i});
    end
end
