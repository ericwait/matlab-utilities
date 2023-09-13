% READIM Reads an image from an IMS file.
%
%   image = READIM(ims_file_path, 'TimePoint', 0, 'Channel', 0, 'ErrorCheck', true, 'ResolutionLevel', 0, 'DatasetInfoNum', '') 
%   reads a specific time point and channel from the IMS file.
%
% Parameters:
%   ims_file_path     - Full path to the IMS file (string).
%   TimePoint         - Optional time point number (numeric, default=0).
%   Channel           - Optional channel number (numeric, default=0).
%   ErrorCheck        - Optional flag for error checking (logical, default=true).
%   ResolutionLevel   - Optional resolution level (numeric, default=0).
%   Dataset    - Optional dataset index (numeric, default='').
%
% Returns:
%   image - The read image data.

function image = ReadIm(ims_file_path, varargin)
    [channel, time_point, resolution_level, dataset_num, error_check] = Ims.DefaultArgParse_(varargin{:});
    
    if error_check
        max_TimePoint = Ims.GetNumberOfTimePoints(ims_file_path, dataset_num); 
        max_Channel = Ims.GetNumberOfChannels(ims_file_path, dataset_num); 
        
        if time_point > max_TimePoint
            error('Requesting a time point larger than %d', max_TimePoint);
        end
        if channel > max_Channel
            error('Requesting a channel larger than %d', max_Channel);
        end
    end
    
    dataset_path = Ims.GetFullDataPath('Dataset', dataset_num, 'Resolution', resolution_level, 'TimePoint', time_point, 'Channel', channel);
    image = h5read(ims_file_path, dataset_path);
end
