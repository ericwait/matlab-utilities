function [prefix,suffix] = GetDirListPrefixSuffix(dList)
    if (isstruct(dList) && isfield(dList,'name'))
        names = {dList.name};
        names = char(names);
    else
        names = dList;
    end

    prefixIndEnd = 0;
    for i=1:size(names,2)
        if (length(unique(names(:,i)))>1)
            break
        end
        prefixIndEnd = i;
    end

    suffixIndStart = size(names,2)+1;
    for i=size(names,2):-1:1
        if (length(unique(names(:,i)))>1)
            break
        end
        suffixIndStart = i;
    end
    
    prefix = names(1,1:prefixIndEnd);
    suffix = names(1,suffixIndStart:end);
    
    [~,suffix] = fileparts(suffix);
end
