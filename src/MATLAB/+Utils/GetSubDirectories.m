function subDirs = GetSubDirectories(rootDir)
% subDirs = Utils.GetSubDirectories(rootDir)
% subDirs are the values from dir that are directories.
%   The special directories . and .. are removed from the list

    dList = dir(rootDir);
    dList = dList([dList.isdir]);
    subDirs = {dList.name};
    subDirs = dList(~cellfun(@(x)(strcmp(x,'.') || strcmp(x,'..')),subDirs));
end
