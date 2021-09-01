function voxel_physical_size_xyz = GetVoxelSize(ims_file_path)
    ext_xyz = Ims.GetImExt(ims_file_path);

    dims_xyz = Ims.GetImDims(ims_file_path);

    voxel_physical_size_xyz = ext_xyz ./ dims_xyz;
end
