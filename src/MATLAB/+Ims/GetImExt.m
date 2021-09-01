function ext_xyz = GetImExt(ims_file_path)
    x_min = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','ExtMin0');
    y_min = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','ExtMin1');
    z_min = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','ExtMin2');

    x_max = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','ExtMax0');
    y_max = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','ExtMax1');
    z_max = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','ExtMax2');

    x_ext = x_max-x_min;
    y_ext = y_max-y_min;
    z_ext = z_max-z_min;
    
    ext_xyz = [x_ext, y_ext, z_ext];
end
