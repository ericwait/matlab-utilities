%GETCHANNELNAMES Retrieve channel names from an .ims file.
%
%   names = GETCHANNELNAMES(ims_file_path) retrieves the names of all channels
%   in the specified .ims file.
%
%   names = GETCHANNELNAMES(ims_file_path, num_channels) retrieves names for
%   a specified number of channels.
%
%   names = GETCHANNELNAMES(ims_file_path, num_channels, 'datasetinfonum', 2)
%   retrieves channel names from a specific DataSet (e.g., the third one) in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   num_channels   - Number of channels to read (numeric, optional).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   names          - Cell array containing channel names.
%
% Example:
%   names = GETCHANNELNAMES('path/to/file.ims');
%   names = GETCHANNELNAMES('path/to/file.ims', 3, 'datasetinfonum', 2);

function names = GetChannelNames(ims_file_path, num_channels, varargin)
    % Create an input parser object
    p = inputParser;

    % Add required and optional arguments
    addRequired(p, 'ims_file_path', @ischar);
    addOptional(p, 'num_channels', [], @isnumeric);

    % Parse the input arguments
    parse(p, ims_file_path, num_channels);

    % Extract the parsed values
    num_channels = p.Results.num_channels;
    
    [~, ~, ~, dataset_num] = Ims.DefaultArgParse_(varargin{:});

    if isempty(num_channels)
        num_channels = Ims.GetNumberOfChannels(ims_file_path, dataset_num);
    end
    
    names = cell(1,num_channels);
    for c = 1:num_channels
        chan_info_path = Ims.CreateChannelInfoStr_('Dataset', dataset_num, 'Channel', c);
        names{c} = Ims.GetAttString_(ims_file_path, chan_info_path, 'Name');
    end
end

