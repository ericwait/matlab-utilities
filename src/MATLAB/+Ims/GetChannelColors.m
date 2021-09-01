function colors = GetChannelColors(ims_file_path, num_channels)
    if ~exist('num_channels','var') || isempty(num_channels)
        num_channels = Ims.GetNumberOfChannels(ims_file_path);
    end
    
    colors = ones(num_channels,3);
    for c=1:num_channels
        color_c = h5readatt(ims_file_path, sprintf('/DataSetInfo/Channel %d',c-1), 'Color');
        color_str = [color_c{:}];
        colors(c,:) = str2double(split(color_str));
    end
end
