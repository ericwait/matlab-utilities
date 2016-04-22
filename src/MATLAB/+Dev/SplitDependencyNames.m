function [rootPath,rootName,localPath] = SplitDependencyNames(depList)
    rootPath = cell(length(depList),1);
    rootName = cell(length(depList),1);
    localPath = cell(length(depList),1);
    
    dropPostfix = {'src/MATLAB'};
    localMatches = '^private$|^\+.+$|^@.+$|^.+\.(m|mexw64|mexw32|fig)$';
    
    for i=1:length(depList)
         qualPath = splitQualifiedPath(depList{i});
         
         bLocalPath = cellfun(@(x)(~isempty(x)),regexp(qualPath,localMatches, 'start','once'));
         endRoot = find(diff(bLocalPath),1,'last');
         if ( isempty(endRoot) )
             % This shouldn't happen if matlab toolboxes are handled first.
             continue;
         end
         
         chkPath = qualPath(1:endRoot);
         for j=1:size(dropPostfix,1)
             chkPostfix = strsplit(dropPostfix{j},'/');
             cmpIdx = length(chkPath)-length(chkPostfix) + 1;
             bDropMatch = strcmp(chkPostfix,chkPath(cmpIdx:end));
             
             if ( all(bDropMatch) )
                 chkPath = chkPath(1:(cmpIdx-1));
                 break;
             end
         end
         
         rootName{i} = chkPath{end};
         rootPath{i} = fullfile(qualPath{1:endRoot});
         localPath{i} = fullfile(qualPath{(endRoot+1):end});
    end
end

function qualPath = splitQualifiedPath(inPath)
    chkPath = strrep(inPath, '\','/');
    
    qualPath = {};
    splitRoot = regexp(chkPath,'^(/{1,2}.+?|.+?:)/(.*?)$','tokens','once');
    if ( ~isempty(splitRoot) )
        qualPath = splitRoot(1);
        chkPath = splitRoot{2};
    end
    
    splitPath = strsplit(chkPath,'/');
    while ( ~isempty(splitPath) )
        popPath = splitPath{1};
        splitPath = splitPath(2:end);
        
        if ( strcmp('.',popPath) )
            continue;
        elseif ( strcmp('..',popPath) )
            qualPath = qualPath(1:end-1);
            continue;
        end
        
        qualPath = [qualPath {popPath}];
    end
end
