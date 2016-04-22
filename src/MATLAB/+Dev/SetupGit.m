function bFoundGit = SetupGit()
    bFoundGit = 0;
    
    [bGitError gitVer] = system('git version');
    if ( ~bGitError )
        bFoundGit = 1;
        return;
    end
    
    gitPath = findGitPath();
    if ( isempty(gitPath) )
        return;
    end
    
    pathEnv = getenv('PATH');
    idx = strfind(pathEnv,gitPath);
    if ( isempty(idx) )
        pathEnv = [gitPath pathsep pathEnv];
        setenv('PATH', pathEnv);
    end
    
    [bGitError gitVer] = system('git version');
    if ( ~bGitError )
        bFoundGit = 1;
        return;
    end
end

function gitPath = findGitPath()
    gitPath = '';
    
    comparch = computer('arch');
    progFilesPath64 = 'C:\Program Files';
    if ( strcmpi(comparch,'win64') )
        progFilesPath = getenv('ProgramFiles(x86)');
        progFilesPath64 = getenv('ProgramFiles');
    elseif ( strcmpi(comparch,'win32') )
        progFilesPath = getenv('ProgramFiles');
    else
        return;
    end
    
    tryPaths = {fullfile(progFilesPath, 'Git');
                fullfile(progFilesPath64, 'Git');
                fullfile(progFilesPath, 'msysgit');
                fullfile(progFilesPath64, 'msysgit');
                'C:\Git';
                'C:\msysgit'};
	
    trySubdir = {'bin';'cmd'};
	
    foundPath = '';
    for i=1:length(tryPaths)
        if ( exist(tryPaths{i}, 'dir') )
            foundPath = tryPaths{i};
            break;
        end
    end
    
    if ( isempty(foundPath) )
        return;
    end
    
    for i=1:length(trySubdir)
        if ( exist(fullfile(foundPath,trySubdir{i},'git.exe'),'file') || exist(fullfile(foundPath,trySubdir{i},'git.cmd'),'file') )
            gitPath = fullfile(foundPath,trySubdir{i});
            return;
        end
    end
end
