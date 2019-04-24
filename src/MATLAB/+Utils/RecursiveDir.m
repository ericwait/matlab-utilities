function list = RecursiveDir(rootDir,fileExtension)
    list = dir(fullfile(rootDir,['**/*.',fileExtension]));
    
    hiddenFileMask = cellfun(@(x)(isempty(x)),regexpi({list.name},'^\.','match'));
    list = list(hiddenFileMask);
end
