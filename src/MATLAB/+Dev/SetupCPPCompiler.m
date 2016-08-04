function [compStruct,comparch] = SetupCPPCompiler(compVer)
    toolsMap = {'vs2015','VS140COMNTOOLS';
                'vs2013','VS120COMNTOOLS';
                'vs2010','VS110COMNTOOLS'};
    
	verMatch = find(strcmp(compVer,toolsMap(:,1)));
    if ( isempty(verMatch) )
        error(['Unrecognized Visual Studio version: ' compVer]);
    end
    
    compStruct.toolroot = getenv(toolsMap{verMatch,2});
    if ( isempty(compStruct.toolroot) )
        error(['Cannot compile c++ files without Visual Studio ' compVer]);
    end

    comparch = computer('arch');
    if ( strcmpi(comparch,'win64') )
        compStruct.buildbits = '64';
        compStruct.buildenv = fullfile(compStruct.toolroot,'..','..','vc','bin','amd64','vcvars64.bat');
        compStruct.buildplatform = 'x64';
    else
        error('Only windows 64-bit builds are currently supported');
    end
    
    system(['"' compStruct.buildenv '"' ]);
end
