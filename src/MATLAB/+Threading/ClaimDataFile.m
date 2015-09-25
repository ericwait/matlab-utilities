function [bExists,bValid] = ClaimDataFile(fileMap, filename)
% USAGE [bExists,bValid] = claimDataFile(fileMap, filename)
% FILEMAP is the map created by initCleanupData.m
% FILENAME is the full file path to the data file you would like to be
% created if it doesn't exist (.mat)
% BEXISTS is a bool that states whether or not the file exists
% BVALID states if the file exist, it is a valid data file

    [bExists,bValid] = Threading.CheckDataFile(filename);
    if ( ~bExists )
        emptyStruct = struct();
        save(filename, '-struct','emptyStruct');

        fileMap(filename) = false;
    end
end
