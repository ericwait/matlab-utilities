% GETIMEXT Get the extent of the image in XYZ dimensions.
%
%   ext_xyz = GETIMEXT(ims_file_path) returns the extent of the image in XYZ.
%   ext_xyz = GETIMEXT(ims_file_path, datasetInfoNum) allows specifying which dataset to consider.
%
% Parameters:
%   ims_file_path   - Path to the .ims file (string).
%   datasetInfoNum  - Optional dataset index for multiple datasets in the .ims file (numeric).
%
% Returns:
%   ext_xyz - 1x3 array [x_ext, y_ext, z_ext] specifying the extent in XYZ dimensions.

function ext_xyz = GetImExt(ims_file_path, dataset_num)
    if nargin < 2
        dataset_num = [];
    end

    dataset_info_str = Ims.CreateImageInfoStr_(dataset_num);
    ext_xyz = zeros(1, 3);

    for i = 1:3
        min_val = Ims.GetAttScalar_(ims_file_path, dataset_info_str, ['ExtMin', num2str(i-1)]);
        max_val = Ims.GetAttScalar_(ims_file_path, dataset_info_str, ['ExtMax', num2str(i-1)]);
        ext_xyz(i) = max_val - min_val;
    end
end
