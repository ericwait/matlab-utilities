function [fileType, validFiles] = CheckImagePath(imPath, datasetName)
    % CheckImagePath checks for files in the specified path with the given
    % dataset name prefix and valid extensions or patterns.
    %
    % Syntax:
    %   [fileType, validFiles] = CheckImagePath(imPath, datasetName)
    %
    % Inputs:
    %   imPath - String, path to the directory containing the image files.
    %   datasetName - String, the prefix of the dataset name to look for in the files.
    %
    % Outputs:
    %   fileType - String, the file extension found ('klb', 'h5', 'tif').
    %   validFiles - Cell array of strings, containing the full paths of valid files.
    %
    % Description:
    %   The function looks for files in the specified directory (imPath) that
    %   have the datasetName as the prefix of the file name and either have a 
    %   valid extension ('klb', 'h5', 'tif') or match one of the patterns 
    %   '%s_c%%02d_t%%04d_z%%04d' or '%s_c%%02d_t%%04d'. It returns the file extension 
    %   found and the valid files that match one of these criteria.

    % Initialize variables
    validFiles = {};
    fileType = '';
    
    % Define valid extensions
    validExtensions = {'klb', 'h5', 'tif'};
    
    % Get list of files in the specified directory
    files = dir(imPath);
    
    % Define regular expressions for patterns
    pattern1 = sprintf('%s_c\\d{2}_t\\d{4}_z\\d{4}', datasetName);
    pattern2 = sprintf('%s_c\\d{2}_t\\d{4}', datasetName);
    
    % Iterate through the files
    for i = 1:length(files)
        [~, name, ext] = fileparts(files(i).name);
        
        % Check if the file has a valid extension
        if any(strcmpi(ext(2:end), validExtensions))
            % Check if the file name starts with the dataset name
            if startsWith(name, datasetName)
                % Check if the file name matches one of the patterns
                if ~isempty(regexp(name, pattern1, 'once')) || ~isempty(regexp(name, pattern2, 'once')) || strcmp(name, datasetName)
                    validFiles{end+1} = fullfile(imPath, files(i).name); %#ok<AGROW>
                    if isempty(fileType)
                        fileType = ext(2:end); % Set fileType if not already set
                    end
                end
            end
        end
    end
end