function json_struct = ReadJSON(file_path)
    f = fopen(file_path,'r');
    json = fread(f, '*char').';
    fclose(f);
    json_struct = Utils.ParseJSON(json);
end
