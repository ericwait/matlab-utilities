% GETNUMBEROFRESOLUTIONS Get the number of resolution levels in a dataset.
%
%   n = GETNUMBEROFRESOLUTIONS(ims_file_path, datasetNum)
%   returns the number of resolution levels for a specific dataset in the IMS file.
%
% Parameters:
%   ims_file_path  - Full path to the IMS file (string).
%   datasetNum - Dataset index (numeric, default='').
%
% Returns:
%   n - Number of resolution levels.

function n = GetNumberOfResolutions(ims_file_path, datasetNum)
    % Create dataset info string
    datasetInfoStr = CreateDatasetInfoStr_(datasetNum);
    
    % Complete path to dataset
    path_to_dataset = [datasetInfoStr, '/DataSet'];
    
    % Read dataset group information
    info = h5info(ims_file_path, path_to_dataset);
    
    % Initialize counter for resolution levels
    n = 0;
    
    % Loop through all groups to find ones that match the pattern 'ResolutionLevel *'
    for i = 1:length(info.Groups)
        if startsWith(info.Groups(i).Name, 'ResolutionLevel')
            n = n + 1;
        end
    end
end
