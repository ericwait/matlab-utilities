function image = ReadIm(ims_file_path, frame, channel, error_check)
    if ~exist('error_check','var') || isempty(error_check)
        error_check = true;
    end

    if error_check
        max_frame = Ims.GetNumberOfImages(ims_file_path);
        max_channel = Ims.GetNumberOfChannels(ims_file_path);
        
        if frame>max_frame
            error('Requesting a frame larger than %d', max_frame);
        end
        
        if channel>max_channel
            error('Requesting a frame larger than %d', max_channel);
        end
    end
    
    image = h5read(ims_file_path, sprintf('/DataSet/ResolutionLevel 0/TimePoint %d/Channel %d/Data', frame-1, channel-1));
end