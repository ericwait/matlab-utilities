function [dataset_info_str] = CreateImageInfoStr_(varargin)
    [~, ~, ~, dataset_num, ~] = Ims.DefaultArgParse_(varargin{:});

    % Construct attribute paths
    dataset_info_str = [Ims.CreateDatasetInfoStr_(dataset_num), '/Image'];
end

