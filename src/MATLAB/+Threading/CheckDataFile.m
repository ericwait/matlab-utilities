function [bExists,bValid] = CheckDataFile(filename)
% USAGE [bExists,bValid] = checkDataFile(filename)
% FILENAME is the full path to the file being used (.mat)
% BEXISTS true if the file exists
% BVALID is true if the file does not exist or it is a valid non-empty
% data file

    bValid = true;
    bExists = false;
    if ( ~exist(filename,'file') )
        return;
    end
    
    chkStruct = whos('-file',filename);
    
    bExists = true;
    bValid = ~isempty(chkStruct);
end