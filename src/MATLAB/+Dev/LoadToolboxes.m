function toolboxPaths = LoadToolboxes(toolboxNodes)
    toolboxMap = Dev.BuildToolboxMap();
    
    toolboxRoot = toolboxdir('');
    toolboxNames = cellfun(@(x)(x(length(toolboxRoot)+2:end)), toolboxNodes, 'UniformOutput',false);
    
    toolboxPaths = {};
    for i=1:length(toolboxNames)
        if ( ~isKey(toolboxMap,toolboxNames{i}) )
            continue;
        end
        
        toolboxPaths = [toolboxPaths; toolboxMap(toolboxNames{i})];
    end
end
