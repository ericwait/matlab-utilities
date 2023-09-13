% GETFULLDATAPATH Construct the full data path using optional, positional arguments.
%
%   path_string = GETFULLDATAPATH() returns a default full data path.
%   path_string = GETFULLDATAPATH(timepoint, channel) sets the timepoint and channel.
%   path_string = GETFULLDATAPATH(Name, Value) allows setting parameters using Name-Value pairs.
%
% Parameters:
%   'Dataset'   - Dataset string (default = '')
%   'Resolution'- Resolution level (default = 0)
%   'TimePoint' - Timepoint (default = 0)
%   'Channel'   - Channel (default = 0)
%
% Returns:
%   path_string - Full data path string.
%
% Example:
%   path_string = GETFULLDATAPATH();
%   path_string = GETFULLDATAPATH(2, 5);
%   path_string = GETFULLDATAPATH('Dataset', 1, 'Resolution', 0, 'TimePoint', 2, 'Channel', 5);

function path_string = GetFullDataPath(varargin)
    [channel, time_point, resolution_level, dataset_num] = Ims.DefaultArgParse_(varargin{:});
    
    % Create individual path components
    datasetStr = Ims.CreateDatasetStr_(dataset_num);
    resolutionStr = Ims.CreateResolutionStr_(resolution_level);
    timePointStr = Ims.CreateTimePointStr_(time_point);
    channelStr = Ims.CreateChannelStr_(channel);
    
    % Combine all components
    path_string = [datasetStr, resolutionStr, timePointStr, channelStr, '/Data'];
end
