function subDirs = GetSubDirectories(rootDir, pattern)
% subDirs = Utils.GetSubDirectories(rootDir)
% subDirs are the values from dir that are directories.
%   The special directories . and .. are removed from the list
    
    dList = dir(rootDir);
    subDirs = {dList([dList.isdir] & ~ismember({dList.name},{'.','..'})).name}';

    matchIndices = cellfun(@(x) ~isempty(regexp(x, pattern, 'once')), subDirs);
    subDirs = subDirs(matchIndices);
end
