function im_val_type = GetImValueType(ims_file_path)
    info = h5info(ims_file_path,'/DataSet/ResolutionLevel 0/TimePoint 0/Channel 0/Data');
    typ = info.Datatype.Type;
    
    im_val_type = 'unknown';
    switch typ
        case 'H5T_NATIVE_UCHAR'
            im_val_type = 'uint8';
        case 'H5T_STD_U8LE'
            im_val_type = 'uint8';
        case 'H5T_NATIVE_USHORT'
            im_val_type = 'uint16';
        case 'H5T_NATIVE_UINT32'
            im_val_type = 'uint32';
        case 'H5T_NATIVE_FLOAT'
            im_val_type = 'single';
        case 'H5T_STD_U16LE'
            im_val_type = 'uint16';
        otherwise
            error('Type unknown');
    end
end
