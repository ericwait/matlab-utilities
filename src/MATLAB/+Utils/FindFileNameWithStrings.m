function mask = FindFileNameWithStrings(dirList,findStr)
    curFileNames = {dirList.name};
    mask = cellfun(@(x)(~isempty(x)),regexpi(curFileNames,findStr))';
end
