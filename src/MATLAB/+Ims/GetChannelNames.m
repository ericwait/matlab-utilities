function names = GetChannelNames(ims_file_path, num_channels)
    if ~exist('num_channels','var') || isempty(num_channels)
        num_channels = Ims.GetNumberOfChannels(ims_file_path);
    end
    
    names = {};
    for c=1:num_channels
        name_c = h5readatt(ims_file_path, sprintf('/DataSetInfo/Channel %d',c-1), 'Name');
        name = [name_c{:}];
        names{c} = name;
    end
end
