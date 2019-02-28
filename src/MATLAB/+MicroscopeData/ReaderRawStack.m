function im = ReaderRawStack(dimensions_xyz,stackPath,voxelType)
    if (~exist('voxelType','var') || isempty(voxelType))
        voxelType = 'uint16';
    end

    f = fopen(stackPath);
    im = fread(f,voxelType);
    fclose(f);

    im = reshape(im,dimensions_xyz([2,1,3]));
end