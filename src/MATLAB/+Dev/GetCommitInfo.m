% [repoName,commitHash] = GetCommitInfo(inPath)
%

function [repoName,commitHash] = GetCommitInfo(inPath)
    remoteUrl = Dev.GitRemote(inPath,'origin');
    
    repoName = '';
    
    tokMatch = regexp(remoteUrl,'\w+@[\w\-.]+:[\w\-.]+/([\w\-]+\.git)', 'tokens','once');
    if ( ~isempty(tokMatch) )
        repoName = tokMatch{1};
    end
    
    commitHash = Dev.GitCommitHash(inPath);
end
