% GETNUMBEROFDATASETS Get the number of datasets in an IMS file.
%
%   n = GETNUMBEROFDATASETS(ims_file_path)
%   returns the number of datasets present in the IMS file specified by ims_file_path.
%
% Parameters:
%   ims_file_path  - Full path to the IMS file (string).
%
% Returns:
%   n - Number of datasets.

function n = GetNumberOfDatasets(ims_file_path)
    % Read root group information
    info = h5info(ims_file_path, '/');
    
    % Initialize counter for datasets
    n = 0;
    
    % Loop through all groups to find ones that match the pattern '/DataSet*'
    for i = 1:length(info.Groups)
        if startsWith(info.Groups(i).Name, '/DataSetInfo')
            n = n + 1;
        end
    end
end
