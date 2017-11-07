function bytes = GetBytesPerVoxel(im)

    dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                      'int8';'int16';'int32';'int64';
                      'single';'double';
                      'logical'};

    dataTypeSize = [1;2;4;8;
                    1;2;4;8;
                    4;8;
                    1];
                
    w = whos('im');
    typeIdx = find(strcmp(w.class,dataTypeLookup));
    if ( ~isempty(typeIdx) )
        bytes = dataTypeSize(typeIdx);
    else
        error('Unsuported pixel type!');
    end
end
