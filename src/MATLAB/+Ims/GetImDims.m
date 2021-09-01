function dims_xyz = GetImDims(ims_file_path, error_check)
    if ~exist('error_check','var') || isempty(error_check)
        error_check = true;
    end

    x_size = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','X');
    y_size = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','Y');
    z_size = Ims.GetAttValue(ims_file_path,'/DataSetInfo/Image','Z');
    
    dims_xyz = [x_size, y_size, z_size];
    
    if error_check
        im = Ims.ReadIm(ims_file_path, 1, 1, false);
        sz = size(im,[2,1,3]);
        if any(dims_xyz ~= sz)
            warning('Using the image data size and not the metadata size for images');
            dims_xyz = sz;
        end        
    end
end