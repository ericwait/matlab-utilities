function FinalizeDataFile(fileMap, filename, varargin)
% USAGE finalizeDataFile(fileMap, filename, varargin)
% FILEMAP is object created from initCleanupData.m
% FILENAME is the full file path the the data file to be used (.mat)
% VARARGIN is the variables to be written to the file, DO NOT SUBREF
%
% This will write the data to the file and delete the claim

    if ( isempty(varargin) )
        return;
    end
    
    fieldNames = cell(1,length(varargin));
    bValid = true(1,length(varargin));
    for i = 1:length(varargin)
        inName = inputname(i+2);
        if ( isempty(inName) )
            bValid(i) = false;
        end
        
        fieldNames{i} = inName;
    end
    
    varStruct = cell2struct(varargin(bValid), fieldNames(bValid), 2);
    
    save(filename,'-struct','varStruct');
    fileMap(filename) = true;
end
