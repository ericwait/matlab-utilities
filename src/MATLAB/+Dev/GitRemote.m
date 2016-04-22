function remoteURL = GitRemote(inPath,remoteName)
    remoteURL = '';
    
    bGit = Dev.SetupGit();
    if ( ~bGit )
        return;
    end
    
    oldDir = cd(inPath);
    cleanupObj = onCleanup(@()(cd(oldDir)));
    
    [status,urlOut] = system(['git remote get-url ' remoteName]);
    if ( status ~= 0 )
        return;
    end
    
    remoteURL = strtrim(urlOut);
end
