function [channel_info_path] = CreateChannelInfoStr_(varargin)
    [channel, ~, ~, dataset_num, ~] = Ims.DefaultArgParse_(varargin{:});

    channel_info_path = sprintf('%s%s', Ims.CreateDatasetInfoStr_(dataset_num), Ims.CreateChannelStr_(channel));
end

