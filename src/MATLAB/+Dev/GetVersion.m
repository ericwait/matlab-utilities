% version = GetVersion(command)
% Get a version string or number depending on the command argument. This
% m-file serves as a single repository for all version-related information.
%
% Note: Uses autogenerated version information in +Dev\VersionInfo.m

function versionStr = GetVersion(command)
    versionStr = [];
    
    verInfo = Dev.LoadVersion();
    
    if ( ~exist('command','var') )
        command = 'string';
    end
    
    % Get rid of slashes in branch names
    cleanBranch  = strrep(verInfo.branchName, '/', '_');
    cleanBranch  = strrep(cleanBranch, '\', '_');
    
    primaryHash = '';
    matchTok = regexp(verInfo.commitHash{1},'.*:\s*(\w+)','tokens','once');
    if ( ~isempty(matchTok) )
        primaryHash = matchTok{1};
    end
    
    if ( strcmpi(command, 'string') || strcmpi(command, 'versionString') )
        versionStr = [num2str(verInfo.majorVersion) '.' num2str(verInfo.minorVersion) ' ' cleanBranch];
        return;
    end
    
    if ( strcmpi(command, 'buildString') )
        versionStr = [verInfo.buildNumber '/' verInfo.buildMachine];
        return;
    end

    if ( strcmpi(command, 'primaryHash') )
        versionStr = primaryHash;
        return
    end
    
    if ( strcmpi(command, 'buildHashes') )
        versionStr = verInfo.commitHash;
        return
    end
    
    if ( strcmpi(command, 'fullString') )
        versionStr = [verInfo.name ' v' num2str(verInfo.majorVersion) '.' num2str(verInfo.minorVersion) ' ' verInfo.buildNumber '/' verInfo.buildMachine ' ' cleanBranch ' ' primaryHash];
        return;
    end
    
    if ( strcmpi(command, 'file') )
        minorStr = num2str(verInfo.minorVersion);
        minorStr = strrep(minorStr, '.', '_');
        versionStr = [num2str(verInfo.majorVersion) minorStr '_' cleanBranch];
        return;
    end
    
end
