%GETIMDIMS Retrieve image dimensions from an .ims file.
%
%   dims_xyz = GETIMDIMS(ims_file_path) retrieves the X, Y, and Z dimensions
%   from the specified .ims file. By default, an error check is performed to
%   validate the metadata dimensions against the actual image data.
%
%   dims_xyz = GETIMDIMS(ims_file_path, true) performs an error check to 
%   validate dimensions.
%
%   dims_xyz = GETIMDIMS(ims_file_path, 'error_check', true) is the same as 
%   the previous usage, but the error check flag is passed as a name-value pair.
%
%   dims_xyz = GETIMDIMS(ims_file_path, 'datasetinfonum', 2) retrieves
%   dimensions from a specific DataSet (for instance, the third one) in the .ims file.
%
% Parameters:
%   ims_file_path  - Path to the .ims file (string).
%   error_check    - Flag to perform an error check against actual data (logical, default=true).
%   datasetinfonum - Dataset index if the .ims file contains multiple datasets (numeric, default='').
%
% Returns:
%   dims_xyz - A 1x3 array containing [X, Y, Z] dimensions.
%
% Example:
%   dims = Ims.GetImDims('path/to/file.ims', true);
%   dims = Ims.GetImDims('path/to/file.ims', 'error_check', true, 'datasetinfonum', 2);
%
% See also: OTHER_RELATED_FUNCTIONS
%

function dims_xyz = GetImDims(ims_file_path, varargin)
    [~, ~, ~, dataset_num, error_check] = Ims.DefaultArgParse_(varargin{:});

    % Construct attribute paths
    dataset_info_str = Ims.CreateImageInfoStr_('Dataset', dataset_num);

    % Retrieve dimensions
    x_size = Ims.GetAttScalar_(ims_file_path, dataset_info_str, 'X');
    y_size = Ims.GetAttScalar_(ims_file_path, dataset_info_str, 'Y');
    z_size = Ims.GetAttScalar_(ims_file_path, dataset_info_str, 'Z');

    % Combine into an array
    dims_xyz = [x_size, y_size, z_size];

    % Optionally perform error check
    if error_check
        im = Ims.ReadIm(ims_file_path, 'ErrorCheck', false, varargin{:});
        sz = size(im,[2,1,3]);
        if any(dims_xyz ~= sz)
            fprintf('Metadata and image data size mismatch -- ');
            fprintf('metadata:(%d, %d, %d), ', x_size, y_size, z_size);
            fprintf('image size:(%d, %d, %d)\n', sz(1), sz(2), sz(3));
            dims_xyz = sz;
        end
    end
end
