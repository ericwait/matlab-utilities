% DefaultArgParse_ - Parse default arguments for IMS file reading.
%
% This function parses both positional and name-value pair arguments for
% reading IMS files. TimePoint and Channel can be passed either as
% positional arguments or as name-value pairs. Other parameters must be
% passed as name-value pairs.
%
% Parameters:
%   varargin - Variable input arguments, can include:
%       TimePoint (optional, positional or named) - The time point to read. Default: 1.
%       Channel (optional, positional or named) - The channel to read. Default: 1.
%       ErrorCheck (optional, named) - Flag for enabling error checking. Default: true.
%       ResolutionLevel (optional, named) - The resolution level to read. Default: 1.
%       Dataset (optional, named) - The dataset number as a string. Default: ''.
%
% Returns:
%   channel - Channel to read.
%   time_point - Time point to read.
%   resolution_level - Resolution level to read.
%   dataset_num - Dataset number as a string.
%   error_check - Flag for enabling or disabling error checking.
%
% Example:
%   [channel, time_point, res_level, dataset_num, error_check] = Ims.DefaultArgParse_('TimePoint', 1, 'Channel', 2);
%   [channel, time_point, resolution_level, dataset_num, error_check] = Ims.DefaultArgParse_(varargin{:});

function [channel, time_point, resolution_level, dataset_num, error_check] = DefaultArgParse_(varargin)
    channel = 1;
    time_point = 1;
    resolution_level = 1;
    dataset_num = 1;
    error_check = true;

    p = inputParser;
    
    % Define name-value pair arguments
    addParameter(p, 'TimePoint', 1, @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'Channel', 1, @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'ErrorCheck', true, @islogical);
    addParameter(p, 'ResolutionLevel', 1, @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'Dataset', '', @(x) ischar(x) || isscalar(x));

    % Strip out any positional arguments
    if nargin > 0 && isscalar(varargin{1})
        time_point = varargin{1};
        if nargin > 1 && isscalar(varargin{2})
            channel = varargin{2};
            varargin = varargin(3:end);
        else
            varargin = varargin(2:end);
        end
    end

    if (isempty(varargin))
        return
    end
    
    % Parse the input arguments
    parse(p, varargin{:});
    
    % Retrieve the values
    time_point = p.Results.TimePoint;
    channel = p.Results.Channel;

    error_check = p.Results.ErrorCheck;
    resolution_level = p.Results.ResolutionLevel;
    if (isempty(p.Results.Dataset) || isscalar(p.Results.Dataset))
        dataset_num = p.Results.Dataset;
    elseif ischar(p.Results.Dataset)
        dataset_num = str2double(p.Results.Dataset);
    else
        error('Wrong format for Dataset argument');
    end
end
