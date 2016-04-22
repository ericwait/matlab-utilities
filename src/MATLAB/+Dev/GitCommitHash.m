function commitHash = GitCommitHash(inPath)
    bGit = Dev.SetupGit();
    if ( ~bGit )
        return;
    end
    
    oldDir = cd(inPath);
    cleanupObj = onCleanup(@()(cd(oldDir)));
    
    [status,hashOut] = system('git rev-parse HEAD');
    if ( status ~= 0 )
        return;
    end
    
    commitHash = strtrim(hashOut);
end
