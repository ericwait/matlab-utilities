function image = ReadIm(ims_file_path, frame, channel, error_check, resolution_level, dataset)
    % Handle optional arguments
    if ~exist('error_check','var') || isempty(error_check)
        error_check = true;
    end
    
    if ~exist('resolution_level','var') || isempty(resolution_level)
        resolution_level = 0; % Default value
    end
    
    if ~exist('dataset','var') || isempty(dataset)
        dataset = ''; % Default value
    else
        dataset = num2str(dataset); % Convert integer to string
    end

    if error_check
        max_frame = Ims.GetNumberOfImages(ims_file_path);
        max_channel = Ims.GetNumberOfChannels(ims_file_path);
        
        if frame > max_frame
            error('Requesting a frame larger than %d', max_frame);
        end
        
        if channel > max_channel
            error('Requesting a channel larger than %d', max_channel);
        end
    end
    
    dataset_path = sprintf('/DataSet%s/ResolutionLevel %d/TimePoint %d/Channel %d/Data', ...
                            dataset, resolution_level, frame - 1, channel - 1);
    image = h5read(ims_file_path, dataset_path);
end
