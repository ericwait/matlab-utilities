% GETIMVALUETYPE Retrieves the value type of image data.
%
%   im_val_type = GETIMVALUETYPE(ims_file_path, TimePoint, Channel, 'key', value, ...) 
%   returns the value type of image data from a specific dataset, resolution, timepoint, 
%   and channel.
%
% Parameters:
%   ims_file_path   - Path to the .ims file (string).
%   TimePoint       - Optional time point index (numeric, default=0).
%   Channel         - Optional channel index (numeric, default=0).
%   'Dataset'       - Optional dataset index (numeric, default='').
%   'Resolution'    - Optional resolution level (numeric, default=0).
%
% Returns:
%   im_val_type - The value type of the image ('uint8', 'uint16', etc.)

function im_val_type = GetImValueType(ims_file_path, varargin)   
    % Generate the full data path
    full_data_path = Ims.GetFullDataPath(varargin{:});
                                     
    % Read HDF5 info
    info = h5info(ims_file_path, full_data_path);
    typ = info.Datatype.Type;
    
    % Determine the value type based on HDF5 type
    switch typ
        case {'H5T_NATIVE_UCHAR', 'H5T_STD_U8LE'}
            im_val_type = 'uint8';
        case {'H5T_NATIVE_USHORT', 'H5T_STD_U16LE'}
            im_val_type = 'uint16';
        case 'H5T_NATIVE_UINT32'
            im_val_type = 'uint32';
        case 'H5T_NATIVE_FLOAT'
            im_val_type = 'single';
        otherwise
            error('Type unknown');
    end
end
