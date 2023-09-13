%GETCHANNELCOLORS Retrieve the colors of channels in an .ims file.
%
%   colors = GETCHANNELCOLORS(ims_file_path) retrieves the colors of all 
%   channels from the specified .ims file.
%
%   colors = GETCHANNELCOLORS(ims_file_path, num_channels) specifies the number
%   of channels to consider.
%
%   colors = GETCHANNELCOLORS(ims_file_path, 'datasetinfonum', 2)
%   retrieves the colors from a specific DataSet (for instance, the third one)
%   in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   num_channels   - Number of channels to consider (numeric, default=auto-detected).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   colors - N x 3 matrix containing RGB values for N channels.
%
% Example:
%   colors = GETCHANNELCOLORS('path/to/file.ims');
%   colors = GETCHANNELCOLORS('path/to/file.ims', 4, 'datasetinfonum', 2);
%
% See also: OTHER_RELATED_FUNCTIONS

function colors = GetChannelColors(ims_file_path, num_channels, varargin)
    [~, ~, ~, dataset_num] = Ims.DefaultArgParse_(varargin{:});

    if isempty(num_channels)
        num_channels = Ims.GetNumberOfChannels(ims_file_path, 'datasetinfonum', dataset_num);
    end

    % Initialize colors matrix
    colors = ones(num_channels, 3);

    % Loop over channels to get colors
    for c = 1:num_channels
        color_path = Ims.CreateChannelInfoStr_('Dataset', dataset_num, 'Channel', c);
        colors(c, :) = Ims.GetAttScalar_(ims_file_path, color_path, 'Color');
    end
end
