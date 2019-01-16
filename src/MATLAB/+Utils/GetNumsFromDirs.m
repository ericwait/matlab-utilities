function [nums,dList] = GetNumsFromDirs(path,pattern)
    dList = dir(path);
    dList = dList(3:end);
    dList = dList([dList.isdir]);
    
    [nums,mask] = Utils.GetNumFromStr({dList.name}',pattern);
    dList = dList(mask);
end