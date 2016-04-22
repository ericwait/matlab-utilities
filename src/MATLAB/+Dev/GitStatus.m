function changeLines = GitStatus(chkPath,chkFiles)
    changeLines = {};
    
    if ( ~exist('chkFiles','var') )
        chkFiles = {};
    end
    
    bGit = Dev.SetupGit();
    if ( ~bGit )
        return;
    end
    
    oldDir = cd(chkPath);
    cleanupObj = onCleanup(@()(cd(oldDir)));
    
    [status,res] = system('git status -uall --porcelain');
    if ( status ~= 0 )
        return;
    end
    
    statusLines = strsplit(res,'\n').';
    
    bValid = cellfun(@(x)(~isempty(x)),statusLines);
    statusLines = statusLines(bValid);
    
    changeTypes = cellfun(@(x)(8*changeMap(x(1)) + changeMap(x(2))), statusLines);
    changeFiles = cellfun(@(x)(x(4:end)), statusLines, 'UniformOutput',false);
    
    if ( isempty(chkFiles) )
        changeLines = changeFiles(changeTypes > 0);
        return;
    end
    
    changeLines = {};
    
    regexpFiles = regexptranslate('escape', strrep(chkFiles, '\','/'));
    for i=1:length(changeFiles)
        matchStarts = regexp(changeFiles{i},regexpFiles, 'start','once');
        bMatched = cellfun(@(x)(~isempty(x)), matchStarts);
        
        if ( any(bMatched) )
            changeLines = [changeLines; changeFiles(i)];
        end
    end
    
    extCell = arrayfun(@(x)([ '.\' x.ext '|']), mexext('all'), 'UniformOutput',false);
    extStr = [extCell{:}];
    bMexFiles = cellfun(@(x)(~isempty(x)), regexp(chkFiles,extStr(1:end-1),'once'));
    if ( any(bMexFiles) )
        matchStarts = regexp(changeFiles,'^src/c/', 'start','once');
        bMatched = cellfun(@(x)(~isempty(x)), matchStarts);
        
        cFiles = changeFiles(bMatched);
        for i=1:length(cFiles)
            changeLines = [changeLines; {'Possible MEX dependency - ' cFiles{i}}];
        end
    end
end

function change = changeMap(c)
    changeList = ['?','M','A','D'];
    
    change = find(c == changeList);
    if ( isempty(change) )
        change = 0;
    end
end
