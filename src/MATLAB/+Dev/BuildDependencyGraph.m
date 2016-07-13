function graphStruct = BuildDependencyGraph(chkPath, bRecurseExternal)
    if ( ~exist('chkPath','var') || isempty(chkPath) )
        chkPath = pwd();
    end
    
    if ( ~exist('bRecurseExternal','var'))
        bRecurseExternal = true;
    end
    
    %% Make sure we get back to our current dir even on error.
    oldDir = cd(chkPath);
    cleanupObj = onCleanup(@()(cd(oldDir)));
    
    %% 
    filenames = getAllFiles(chkPath);
    
    %% Initialize sparse matrix assuming a fanout of about 10x
    n = length(filenames);
    graphStruct = struct('nodes',{filenames}, 'graph',{sparse([],[],[],n,n,10*n)});
    
    graphStruct = recursiveGetDeps(chkPath, graphStruct, filenames, bRecurseExternal);
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

function graphStruct = recursiveGetDeps(localPath,graphStruct, checkNames, bRecurseExternal)
    if ( isempty(checkNames) )
        return;
    end

    newEntries = {};
    
    matRoot = matlabroot();
    % Get single-link dependencies
    for i=1:length(checkNames)
        [fList,pList] = matlab.codetools.requiredFilesAndProducts(checkNames{i}, 'toponly');
        toolboxes = arrayfun(@(x)(fullfile(matRoot,'toolbox',x.Name)),pList, 'UniformOutput',false);

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
    bMatlab = strncmp(matRoot,newEntries, length(matRoot));
    newEntries = newEntries(~bMatlab);
    if ( ~bRecurseExternal )
        bNewLocal = strncmp(localPath,newEntries, length(localPath));
        newEntries = newEntries(bNewLocal);
    end
    
    % Add java jar/class dependencies
    % IMPORTANT: This assumes that ALL files in the same folder as the
    % JAR or CLASS file depend upon it and that these are the ONLY direct
    % dependencies on the java classes!
    graphStruct = checkJavaDeps(graphStruct,newEntries);
    
    graphStruct = recursiveGetDeps(localPath,graphStruct, newEntries, bRecurseExternal);
end

function graphStruct = checkJavaDeps(graphStruct,checkNodes)
    [checkDirs,~,ic] = unique(cellfun(@(x)(fileparts(x)),checkNodes, 'UniformOutput',false));
    
    for i=1:length(checkDirs)
        jarList = dir(fullfile(checkDirs{i},'*.jar'));
        classList = dir(fullfile(checkDirs{i},'*.class'));
        
        javaNodes = arrayfun(@(x)(fullfile(checkDirs{i},x.name)), [jarList;classList], 'UniformOutput',false);
        if ( isempty(javaNodes) )
            continue;
        end
        
        depNodes = checkNodes(ic==i);
        [javaGraph,mergeNodes] = createCompleteCallGraph(depNodes,javaNodes);
        newStruct = struct('nodes',{mergeNodes},'graph',{javaGraph});
        
        graphStruct = Dev.MergeGraphStruct(graphStruct,newStruct);
    end
end

% This creates a completely connected caller->callee graph, there cannot be
% any overlap in caller/callee nodes.
function [callGraph,mergeNodes] = createCompleteCallGraph(callerNodes,callNodes)
    [iIdx,jIdx] = ndgrid(1:length(callerNodes),length(callerNodes)+(1:length(callNodes)));
    
    numEdges = numel(jIdx);
    
    mergeNodes = [callerNodes;callNodes];
    callGraph = sparse(iIdx(:),jIdx(:), ones(numEdges,1), length(mergeNodes),length(mergeNodes));
end

% This uses a pre-merged node entry list with a single caller and connects
% the caller to all the other nodes in the graph.
function callGraph = createCallGraph(callerIdx,newNodes)
    jIdx = setdiff(1:length(newNodes),callerIdx);
    iIdx = repmat(callerIdx,1,length(jIdx));

    callGraph = sparse(iIdx,jIdx, ones(1,length(jIdx)), length(newNodes),length(newNodes));
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
