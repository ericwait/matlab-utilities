function toolboxMap = BuildToolboxMap()
    toolboxRoot = toolboxdir('');
    toolboxMap = containers.Map('keyType','char', 'valueType','any');
    
    % Ignore fixPoint, because
    toolboxList = dir(toolboxRoot);
    
    bInvalidName = arrayfun(@(x)(strcmp(x.name,'.') || strcmp(x.name,'..') || strcmp(x.name,'fixpoint')), toolboxList);
    bValidDir = ~bInvalidName & (vertcat(toolboxList.isdir) > 0);
    toolboxList = toolboxList(bValidDir);
    
    % Always add local/shared directory to matlab 
    toolboxMap('MATLAB') = {fullfile(toolboxRoot,'local');fullfile(toolboxRoot,'shared')};
    
    for i=1:length(toolboxList)
        verStruct = ver(toolboxList(i).name);
        if ( isempty(verStruct) )
            continue;
        end
        
        if ( isKey(toolboxMap,verStruct.Name) )
            toolboxMap(verStruct.Name) = [toolboxMap(verStruct.Name); {fullfile(toolboxRoot,toolboxList(i).name)}];
        else
            toolboxMap(verStruct.Name) = {fullfile(toolboxRoot,toolboxList(i).name)};
        end
    end
end
