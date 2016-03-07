function graphStruct = BuildDependencyGraph(chkPath)
    if ( ~exist('chkPath','var') || isempty(chkPath) )
        chkPath = pwd();
    end
    
    %% Make sure we get back to our current dir even on error.
    oldDir = cd(chkPath);
    cleanupObj = onCleanup(@()(cd(oldDir)));
    
    %% 
    filenames = getAllFiles(chkPath);
    
    %% Initialize sparse matrix assuming a fanout of about 10x
    n = length(filenames);
    graphStruct = struct('nodes',{filenames}, 'graph',{sparse([],[],[],n,n,10*n)});
    
    graphStruct = recursiveGetDeps(chkPath, graphStruct, filenames);
    graphStruct = sortNodes(chkPath,graphStruct);
end

function graphStruct = sortNodes(localPath, graphStruct)
    bLocal = strncmp(localPath,graphStruct.nodes, length(localPath));
    localIdx = find(bLocal);
    externalIdx = find(~bLocal);
    
    %% Sort lexicographically, but all local functions are first.
    [~,localSrt] = sort(graphStruct.nodes(bLocal));
    [~,externalSrt] = sort(graphStruct.nodes(~bLocal));
    
    srtIdx = [localIdx(localSrt); externalIdx(externalSrt)];
    
    graphStruct.nodes = graphStruct.nodes(srtIdx);
    graphStruct.graph = graphStruct.graph(srtIdx,:);
    graphStruct.graph = graphStruct.graph(:,srtIdx);
end

function graphStruct = recursiveGetDeps(localPath,graphStruct, checkNames)
    if ( isempty(checkNames) )
        return;
    end

    newEntries = {};
    
    % Get single-link dependencies
    for i=1:length(checkNames)
        [fList,pList] = matlab.codetools.requiredFilesAndProducts(checkNames{i}, 'toponly');
        toolboxes = arrayfun(@(x)(fullfile(matlabroot(),'toolbox',x.Name)),pList, 'UniformOutput',false);

        selfIdx = find(strcmp(checkNames{i},fList));
        if ( isempty(selfIdx) )
            selfIdx = 1;
            fList = [checkNames(i) fList];
        end
        
        newNodes = [fList.'; toolboxes.'];
        newGraph = createCallGraph(selfIdx, newNodes);
        newStruct = struct('nodes',{newNodes},'graph',{newGraph});

        [graphStruct,addedNodes] = Dev.MergeGraphStruct(graphStruct, newStruct);
        newEntries = [newEntries; addedNodes];
    end
    
    % Don't recurse through external dependencies
    bNewLocal = strncmp(localPath,newEntries, length(localPath));
    newEntries = newEntries(bNewLocal);
    
    graphStruct = recursiveGetDeps(localPath,graphStruct, newEntries);
end

function callGraph = createCallGraph(callerIdx,newNodes)
    jIdx = setdiff(1:length(newNodes),callerIdx);
    iIdx = repmat(callerIdx,1,length(jIdx));

    callGraph = sparse(iIdx,jIdx, ones(1,length(jIdx)), length(newNodes),length(newNodes), length(jIdx));
end

function fullNames = getAllFiles(dirName)
    matlabFiles = what(dirName);

    funcFileNames = vertcat(matlabFiles.m);
    funcFileNames = [funcFileNames; vertcat(matlabFiles.mex)];
    
    fullNames = cellfun(@(x)(fullfile(dirName,x)), funcFileNames, 'UniformOutput',false);

    for i=1:length(matlabFiles.packages)
        pkgFullNames = getAllFiles(fullfile(dirName, ['+' matlabFiles.packages{i}]));
        fullNames = [fullNames; pkgFullNames];
    end
    
    for i=1:length(matlabFiles.classes)
        classDir = fullfile(dirName, ['@' matlabFiles.classes{i}]);
        if ( ~exist(classDir,'dir') )
            continue;
        end
        
        classFullNames = getAllFiles(classDir);
        fullNames = [fullNames; classFullNames];
    end
end
