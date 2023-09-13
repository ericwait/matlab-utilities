%GETNUMBEROFCHANNELS Retrieve information about channels in an .ims file.
%
%   [num_channels, names, colors] = GETNUMBEROFCHANNELS(ims_file_path) 
%   retrieves the number of channels, their names, and their colors from the
%   specified .ims file.
%
%   [num_channels, names, colors] = GETNUMBEROFCHANNELS(ims_file_path, 'datasetinfonum', 2)
%   retrieves the information from a specific DataSet (for instance, the third one)
%   in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   num_channels - Number of channels (numeric).
%   names        - Names of the channels (cell array of strings).
%   colors       - Colors of the channels (array or matrix).
%
% Example:
%   [num_channels, names, colors] = GETNUMBEROFCHANNELS('path/to/file.ims');
%   [num_channels, names, colors] = GETNUMBEROFCHANNELS('path/to/file.ims', 'datasetinfonum', 2);
%
% See also: OTHER_RELATED_FUNCTIONS

function [num_channels, names, colors] = GetNumberOfChannels(ims_file_path, varargin)
    [~, ~, ~, dataset_num] = Ims.DefaultArgParse_(varargin{:});

    % Create an input parser object
    p = inputParser;

    % Add required and optional arguments
    addRequired(p, 'ims_file_path', @ischar);

    % Parse the input arguments
    parse(p, ims_file_path);

    % Retrieve information
    info = h5info(ims_file_path, Ims.CreateDatasetInfoStr_(dataset_num));
    names = {info.Groups.Name};
    tok = regexpi(names, 'Channel (\d+)', 'tokens');
    tok_mask = cellfun(@(x)(~isempty(x)), tok);
    vals = cellfun(@(x)(str2double(x{1})), tok(tok_mask));
    num_channels = max(vals) + 1;

    if nargout > 1
        names = Ims.GetChannelNames(ims_file_path, num_channels, varargin{:});
    end
    if nargout > 2
        colors = Ims.GetChannelColors(ims_file_path, num_channels, varargin{:});
    end
end
