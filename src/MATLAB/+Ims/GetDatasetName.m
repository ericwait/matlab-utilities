function dataset_name = GetDatasetName(ims_file_path)
    val_c = h5readatt(ims_file_path,'/DataSetInfo/Image','Name');
    dataset_name = [val_c{:}];
    
    if strfind(dataset_name,'name not specified')~=0
        [~,dataset_name] = fileparts(ims_file_path);
    end
end
