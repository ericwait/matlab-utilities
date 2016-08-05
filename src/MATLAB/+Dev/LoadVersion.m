function verInfo = LoadVersion()
    %% Use compiled VersionInfo function when deployed
    if ( isdeployed )
        verInfo = Dev.VersionInfo();
        return;
    end
    
    %% Try to load version tag and branch using git
    bFoundGit = Dev.SetupGit();
    verInfo = [];
    if ( bFoundGit )
        chkVerInfo = gitVersionInfo();
    end
    
    %% Use fallback file for name (set by Dev.MakeVersion)
    fallbackFile = 'version.json';
    
    fallbackVerInfo = loadFallbackInfo(fallbackFile);
    if ( isempty(fallbackVerInfo) )
        fprintf('WARNING: Invalid fallback file, unable to load version information.\n');
        return;
    end
    
    if ( isempty(chkVerInfo) )
        fprintf('WARNING: Could not find git directory, using fallback %s\n', fallbackFile);
        chkVerInfo = fallbackVerInfo;
    end
    
    % Always use the name from fallback file
    chkVerInfo.name = fallbackVerInfo.name;
    
    verInfo = chkVerInfo;
end

%% Read fallback json version file
function verInfo = loadFallbackInfo(fallbackFile)
    verInfo = [];
    
    fid = fopen(fallbackFile);
    if ( fid <= 0 )
        return;
    end
        
    jsonVer = fread(fid, '*char').';
    fclose(fid);
    
    verInfo = Utils.ParseJSON(jsonVer);
end

%% Use git tags to get version information
function verInfo = gitVersionInfo()
    verInfo = [];
    
    [verStatus,verString] = system('git describe --tags --match v[0-9]*.[0-9]* --abbrev=0');
    [branchStatus,branchString] = system('git rev-parse --abbrev-ref HEAD');
    
    [majorVer,minorVer] = Dev.ParseVerTag(verString);

    if ( verStatus ~= 0 || isempty(majorVer) || isempty(minorVer) )
        fprintf('WARNING: There was an error retrieving tag from git:\n %s\n', verString);
        return;
    end

    branchName = strtrim(branchString);
    if ( branchStatus ~= 0 )
        fprintf('WARNING: There was an error retrieving branch name from git:\n %s\n', branchName);
        return;
    end
    
    [repoName,commitHash] = Dev.GetCommitInfo(pwd());
    commitString = [repoName ' : ' commitHash];
    
    %% VersionInfo default structure
    verInfo = struct(...
        'name',{repoName},...
        'majorVersion',{majorVer},...
        'minorVersion',{floor(minorVer)+1},...
        'branchName',{branchName},...
        'buildNumber',{'UNKNOWN'},...
        'buildMachine',{'UNKNOWN'},...
        'commitHash',{{commitString}});
end
