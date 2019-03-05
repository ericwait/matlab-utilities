function im = ReaderRawStack(dimensions_xyz,stackPath,voxelType)
    if (~exist('voxelType','var') || isempty(voxelType))
        voxelType = 'uint16';
    end

    f = fopen(stackPath);
    im = fread(f,voxelType);
    fclose(f);
    
    switch voxelType
        case 'uint8'
            im = uint8(im);
        case 'int8'
            im = int8(im);
        case 'uint16'
            im = uint16(im);
        case 'int16'
            im = int16(im);
        case 'uint32'
            im = uint32(im);
        case 'int32'
            im = int32(im);
        case 'single'
            im = single(im);
        case 'double'
            im = double(im);
        otherwise
            error('Unknown voxel type');
    end

    im = reshape(im,dimensions_xyz([2,1,3]));
end