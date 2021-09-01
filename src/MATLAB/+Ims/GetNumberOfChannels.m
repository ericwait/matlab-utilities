function [num_channels, names, colors] = GetNumberOfChannels(ims_file_path)
    info = h5info(ims_file_path,'/DataSetInfo');
    names = {info.Groups.Name};
    tok = regexpi(names,'channel (\d+)','tokens');
    tok_mask = cellfun(@(x)(~isempty(x)),tok);
    vals = cellfun(@(x)(str2double(x{1})),tok(tok_mask));
    num_channels = max(vals) +1;
    
    if nargout>1
        names = Ims.GetChannelNames(ims_file_path, num_channels);
    end
    if nargout>2
        colors = Ims.GetChannelColors(ims_file_path, num_channels);
    end
end
