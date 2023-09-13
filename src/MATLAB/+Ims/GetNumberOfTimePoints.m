%GETNUMBEROFTIMEPOINTS Retrieve the number of time points in an .ims file.
%
%   num_im = GETNUMBEROFTIMEPOINTS(ims_file_path) retrieves the number of 
%   time points from the specified .ims file.
%
%   num_im = GETNUMBEROFTIMEPOINTS(ims_file_path, 'datasetinfonum', 2)
%   retrieves the number from a specific DataSet (for instance, the third one)
%   in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   num_im - Number of time points (numeric).
%
% Example:
%   num_im = GETNUMBEROFTIMEPOINTS('path/to/file.ims');
%   num_im = GETNUMBEROFTIMEPOINTS('path/to/file.ims', 'datasetinfonum', 2);
%
% See also: OTHER_RELATED_FUNCTIONS

function num_im = GetNumberOfTimePoints(ims_file_path, varargin)
    [~, ~, ~, dataset_num] = Ims.DefaultArgParse_(varargin{:});

    % Construct attribute path
    time_info_path = [Ims.CreateDatasetInfoStr_(dataset_num), '/TimeInfo'];

    % Retrieve the number of time points
    num_im = Ims.GetAttScalar_(ims_file_path, time_info_path, 'FileTimePoints');
end
