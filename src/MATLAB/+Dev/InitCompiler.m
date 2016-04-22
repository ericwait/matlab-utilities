function initStruct = InitCompiler(productName,forceVersion)
    if ( ~exist('forceVersion','var') )
        forceVersion = '';
    end
    
    rootDir = pwd();
    
    initStruct = [];
    
    %% Build dependency graph for current directory
    depGraph = Dev.BuildDependencyGraph(rootDir,true);

    %% Get list of matlab toolbox dependencies
    toolboxRoot = toolboxdir('');
    bMatlab = strncmp(toolboxRoot,depGraph.nodes, length(toolboxRoot));

    toolboxNodes = depGraph.nodes(bMatlab);
    toolboxList = Dev.LoadToolboxes(toolboxNodes);

    %% Remove matlab paths/dependencies
    depGraph.nodes = depGraph.nodes(~bMatlab);
    depGraph.graph = depGraph.graph(~bMatlab,~bMatlab);
    
    %% Get rootPaths and local subdirectories for dependencies
    [rootPaths,rootNames,localPaths] = Dev.SplitDependencyNames(depGraph.nodes);
    
    %% Verify no uncommited changes on dependencies
    changeString = {};
    [chkPaths,ia,ic] = unique(rootPaths);
    chkNames = rootNames(ia);
    for i=1:length(chkPaths)
        bInPath = (ic == i);
        changeLines = Dev.GitStatus(chkPaths{i},localPaths(bInPath));
        
        if ( ~isempty(changeLines) )
            changeString = [changeString; {[chkNames{i} ' (' chkPaths{i} '):']}];
            for j=1:length(changeLines)
                changeString = [changeString; {['    ' changeLines{j}]}];
            end
        end
    end
    
    if ( ~isempty(changeString) )
        message = sprintf('The following dependencies have uncommitted changes, are you sure you wish to continue?\n\n');
        for i=1:length(changeString)
            message = [message sprintf('%s\n',changeString{i})];
        end
        
        answer = questdlg(message, 'Uncommitted changes!', 'Continue','Cancel', 'Cancel');
        if ( strcmpi(answer,'Cancel') )
            initStruct = [];
            return;
        end
    end
    
    %% Make full version string and fallback version file
    Dev.MakeVersion(productName,forceVersion,chkPaths);

    %% Copy the external dependencies to local paths
    bExternal = ~strncmp(rootDir,rootPaths,length(rootDir));
    externalPaths = rootPaths(bExternal);
    externalDeps = localPaths(bExternal);
    
    copyPaths = {};
    for i=1:length(externalPaths)
        localDir = fileparts(externalDeps{i});
        if ( ~exist(fullfile(rootDir,localDir),'dir') )
            mkdir(fullfile(rootDir,localDir));
        end
        
        copyPaths = [copyPaths; fullfile(rootDir,externalDeps{i})];
        copyfile(fullfile(externalPaths{i},externalDeps{i}), fullfile(rootDir,externalDeps{i}));
    end
    
    initStruct.toolboxList = toolboxList;
    initStruct.cleanupObj = onCleanup(@()(compilerCleanup(copyPaths)));
    
    % temporarily remove any startup scripts that would normally be run by matlabrc
    enableStartupScripts(false);
end

function compilerCleanup(copyPaths)
    % Remove all copied dependencies
    for i=1:length(copyPaths)
        if ( exist(copyPaths{i},'file') )
            delete(copyPaths{i});
        end
    end
    
    % Re-enable any disabled startup scripts
    enableStartupScripts(true);
end

function enableStartupScripts(bEnable)
    searchPrefix = '';
    renamePrefix = 'disabled_';
    if ( bEnable )
        searchPrefix = 'disabled_';
        renamePrefix = '';
    end
    
    searchName = [searchPrefix 'startup.m'];
    newName = [renamePrefix 'startup.m'];
    
    startupScripts = findFilesInPath(searchName, userpath);
    for i=1:length(startupScripts)
        scriptPath = fileparts(startupScripts{i});
        movefile(startupScripts{i}, fullfile(scriptPath,newName));
    end
end

function fullNames = findFilesInPath(filename, searchPaths)
    fullNames = {};
    
    chkPaths = [];
    while ( ~isempty(searchPaths) )
        [newPath remainder] = strtok(searchPaths, pathsep);
        if ( isempty(newPath) )
            searchPaths = remainder;
            continue;
        end
        
        chkPaths = [chkPaths; {newPath}];
        searchPaths = remainder;
    end
    
    for i=1:length(chkPaths)
        chkFullPath = fullfile(chkPaths{i}, filename);
        if ( exist(chkFullPath, 'file') )
            fullNames = [fullNames; {chkFullPath}];
        end
    end
end

