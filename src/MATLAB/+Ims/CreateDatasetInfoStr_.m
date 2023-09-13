% _CREATE_DATASET_INFO_STR Create the dataset info string based on the datasetInfoNum.
%
%   datasetInfoStr = _CREATE_DATASET_INFO_STR(datasetInfoNum) creates the dataset 
%   info string, including the '/DataSetInfo' prefix, to be used in constructing 
%   attribute paths in other functions.
%
% Parameters:
%   datasetInfoNum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   datasetInfoStr - Dataset info string including '/DataSetInfo' prefix. 
%                    Will be empty if datasetInfoNum is empty.
%
% Example:
%   datasetInfoStr = _CREATE_DATASET_INFO_STR(2);  % Output: '/DataSetInfo2'
%   datasetInfoStr = _CREATE_DATASET_INFO_STR([]); % Output: '/DataSetInfo'
%
function dataset_str = CreateDatasetInfoStr_(dataset_num)
    if isempty(dataset_num) || dataset_num==1
        dataset_str = '';
    else
        dataset_str = sprintf('%d', dataset_num -1);
    end
    dataset_str = sprintf('/DataSetInfo%s', dataset_str);
end
