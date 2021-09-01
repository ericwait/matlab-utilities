function val = GetAttValue(file_path, att_path, att)
    val_c = h5readatt(file_path, att_path, att);
    val = str2double([val_c{:}]);
end
