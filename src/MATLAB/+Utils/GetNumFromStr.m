function [nums, mask] = GetNumFromStr(strs,pattern)
    tok = regexp(strs,pattern,'tokens');
    nums = [];
    mask = false(length(strs),1);
    for i=1:length(tok)
        curTok = tok{i};
        if (~isempty(curTok))
            nums(end+1) = str2double(curTok{1});
            mask(i) = true;
        end
    end
end
