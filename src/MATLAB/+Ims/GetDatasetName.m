%GETDATASETNAME Retrieve the dataset name from an .ims file.
%
%   dataset_name = GETDATASETNAME(ims_file_path) retrieves the dataset name
%   from the specified .ims file. If the name is not specified, the file name
%   is used as the dataset name.
%
%   dataset_name = GETDATASETNAME(ims_file_path, 'datasetinfonum', 2) retrieves
%   the name from a specific DataSet (for instance, the third one) in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   dataset_name - The name of the dataset.
%
% Example:
%   name = Ims.GetDatasetName('path/to/file.ims');
%   name = Ims.GetDatasetName('path/to/file.ims', 'datasetinfonum', 2);
%
% See also: OTHER_RELATED_FUNCTIONS

function dataset_name = GetDatasetName(ims_file_path, varargin)
    % Construct attribute path
    dataset_info_path = Ims.CreateImageInfoStr_(varargin{:});

    % Retrieve the dataset name
    dataset_name = Ims.GetAttString_(ims_file_path, dataset_info_path, 'Name');

    % Use file name if dataset name is not specified
    if strfind(dataset_name, 'name not specified') ~= 0
        [~, dataset_name] = fileparts(ims_file_path);
    end
end
