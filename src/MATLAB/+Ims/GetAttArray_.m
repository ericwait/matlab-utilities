%GETATTARRAY_ Retrieve an array attribute from an HDF5 file.
%
%   val = GETATTARRAY_(file_path, att_path, att) retrieves the specified 
%   attribute (att) from the provided attribute path (att_path) in the given 
%   HDF5 file (file_path). The returned value is a double array.
%
% Parameters:
%   file_path  - Path to the HDF5 file (string).
%   att_path   - Path to the attribute in the HDF5 hierarchy (string).
%   att        - Name of the attribute to retrieve (string).
%
% Returns:
%   val        - A double array representing the specified attribute.
%
% Example:
%   value = GETATTARRAY_('path/to/file.h5', '/Group/SubGroup', 'AttributeName');
%
% See also: h5readatt

function val = GetAttArray_(file_path, att_path, att)
    val_c = h5readatt(file_path, att_path, att);
    val_str = [val_c{:}];
    val = str2double(strsplit(val_str, ' '));
end
