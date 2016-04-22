% [majorVer,minorVer] = ParseVerTag(verString)
% 

function [majorVer,minorVer] = ParseVerTag(verString)
    majorVer = [];
    minorVer = [];
    
    verString = strtrim(verString);
    
    numTok = regexp(verString, '[Vv](\d+)\.(\d+(?:\.\d+)?).*', 'tokens', 'once');
    if ( length(numTok) >= 2 )
        majorVer = str2double(numTok{1});
        minorVer = str2double(numTok{2});
    end
end
