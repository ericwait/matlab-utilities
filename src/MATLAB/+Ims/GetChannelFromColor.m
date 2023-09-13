%GETCHANNELFROMCOLOR Retrieve a channel number based on the color set in Imaris.
%
%   channel = GETCHANNELFROMCOLOR(ims_file_path, color) retrieves the channel
%   number in the .ims file with the specified color.
%
%   channel = GETCHANNELFROMCOLOR(ims_file_path, color, 'datasetinfonum', 2)
%   retrieves the channel number from a specific DataSet (e.g., the third one)
%   in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   color          - 1x3 array of RGB values ranging from [0, 1] (numeric).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   channel        - Channel number with the specified color. Returns -1 if no channel is found.
%
% Example:
%   channel = GETCHANNELFROMCOLOR('path/to/file.ims', [1, 0, 0]);
%   channel = GETCHANNELFROMCOLOR('path/to/file.ims', [1, 0, 0], 'datasetinfonum', 2);

function channel = GetChannelFromColor(ims_file_path, color, varargin)
    % Create an input parser object
    p = inputParser;

    % Define default values for optional input arguments
    defaultDatasetInfoNum = '';

    % Add required and optional arguments
    addRequired(p, 'ims_file_path', @ischar);
    addRequired(p, 'color', @(x) isnumeric(x) && numel(x) == 3);
    addParameter(p, 'dataset', defaultDatasetInfoNum, @(x) isnumeric(x) || isempty(x));

    % Parse the input arguments
    parse(p, ims_file_path, color, varargin{:});

    % Extract the parsed values
    dataset_num = p.Results.dataset;
    
    % Get channel colors for the given dataset
    colors = Ims.GetChannelColors(ims_file_path, 'datasetinfonum', dataset_num);

    if isdiag(colors)
        warning('This looks like the default R,G,B color order to me');
    end
    
    channel = find(ismember(colors, color, 'rows'));

    if isempty(channel)
        channel = -1;
    end
end
