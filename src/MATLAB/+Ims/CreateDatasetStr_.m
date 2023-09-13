% _CREATE_DATASET_STR Create the dataset string based on the datasetNum.
%
%   datasetStr = _CREATE_DATASET_STR(datasetNum) creates the dataset 
%   string, including the '/Dataset' prefix, to be used in constructing 
%   attribute paths in other functions.
%
% Parameters:
%   datasetNum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   datasetStr - Dataset string including '/Dataset' prefix. 
%                Will be empty if datasetNum is empty.
%
% Example:
%   datasetStr = _CREATE_DATASET_STR(2);  % Output: '/Dataset2'
%   datasetStr = _CREATE_DATASET_STR([]); % Output: '/Dataset'
%
function dataset_str = CreateDatasetStr_(dataset_num)
    if isempty(dataset_num) || dataset_num==1
        dataset_str = '';
    else
        dataset_str = sprintf('%d', dataset_num -1);
    end
    dataset_str = sprintf('/DataSet%s', dataset_str);
end
