function [nums,dList] = GetNumsFromFiles(path,pattern,extension)
    dList = dir(fullfile(path,['*.',extension]));
    
    [nums,mask] = Utils.GetNumFromStr({dList.name}',pattern);
    dList = dList(mask);
end