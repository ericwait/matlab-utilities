% READALLIMAGES Reads all images from an IMS file for specified time points and channels.
%
%   images = READALLIMAGES(ims_file_path, 'TimePoint', 0:5, 'Channel', 0:2, 'ErrorCheck', false, 'ResolutionLevel', 0, 'DatasetInfoNum', '')
%   reads all images for specific time points and channels from the IMS file.
%
% Parameters:
%   ims_file_path     - Full path to the IMS file (string).
%   TimePoint         - Optional time point numbers (array, default=all).
%   Channel           - Optional channel numbers (array, default=all).
%   ErrorCheck        - Optional flag for error checking (logical, default=false).
%   ResolutionLevel   - Optional resolution level (numeric, default=0).
%   DatasetInfoNum    - Optional dataset index (numeric, default='').
%
% Returns:
%   images - The read image data.

function images = ReadAllImages(ims_file_path, time_points, channels, varargin)
    if (~exist('time_points', 'var') || isempty(time_points))
        time_points = 0:Ims.GetNumberOfTimePoints(ims_file_path) - 1;
    end
    if (~exist('channels', 'var') || isempty(channels))
        channels = 0:Ims.GetNumberOfChannels(ims_file_path) - 1;
    end

    [~, ~, resolution_level, dataset, error_check] = Ims.DefaultArgParse_(varargin{:});
    
    [dims, permute_ind, image_size_xyz] = Ims.GetImDims(ims_file_path, 'Dataset', dataset);
    im_val_type = Ims.GetImValueType(ims_file_path, 'Dataset', dataset);
    
%     dims = dims(permute_ind);
    images = zeros([image_size_xyz([2,1,3]), numel(channels), numel(time_points)], im_val_type);
    
    for t_idx = 1:numel(time_points)
        for c_idx = 1:numel(channels)
            images(:,:,:,c_idx,t_idx) = Ims.ReadIm(ims_file_path, 'TimePoint', time_points(t_idx), 'Channel', channels(c_idx), 'ErrorCheck', error_check, 'ResolutionLevel', resolution_level, 'Dataset', dataset);
        end
    end
end
